# frozen_string_literal: true

require "tempfile"
require "fileutils"
require "shellwords"
require "pdf/reader"

class Importar::OpPdfService
  class ImportError < StandardError; end

  def initialize(pdf_url)
    @pdf_url = pdf_url
  end

  # Retorna um resumo do que fez (útil pra log/sidekiq)
  def call!
    pdf_path = download_pdf!(@pdf_url)

    ops_saved = 0
    itens_saved = 0

    last_op = nil # para páginas continuação
    pages_text = extract_pages_text(pdf_path)

    ActiveRecord::Base.transaction do
      pages_text.each_with_index do |page_text, idx|
        # 1) tenta parsear cabeçalho
        header = HeaderParser.parse(page_text)
        debugger

        # Se não achou OP/PCP, assume continuação da última OP
        if header[:op_n].blank?
          raise ImportError, "Página #{idx + 1}: não encontrei OP/PCP e não existe OP anterior (continuação inválida)." if last_op.nil?

          header[:op_n] = last_op.op_n
          header[:pedido_venda] = last_op.pedido_venda if header[:pedido_venda].blank?
          header[:quantidade]   = last_op.quantidade if header[:quantidade].blank?
          header[:observacoes]  = last_op.observacoes if header[:observacoes].blank?
        end

        operacao = Operacao.find_or_initialize_by(numero: header[:op_n])

        # Atualiza dados principais (sem apagar info já existente se vier vazio)
        operacao.pedido_venda = header[:pedido_venda] if header[:pedido_venda].present?
        operacao.qtd   = header[:quantidade]   if header[:quantidade].present?
        operacao.observacao  = header[:observacoes]  if header[:observacoes].present?

        operacao.save! if operacao.changed?
        ops_saved += 1 if operacao.previous_changes.present?

        # 2) parseia itens da tabela
        items = ItemTableParser.parse(page_text)

        items.each do |it|
          # Ajuste para seus campos reais em OperacaoItens:
          # exemplo: operacao_id, qtd, descricao
          OperacaoItem.create!(
            operacao_id: operacao.id,
            qtd: it[:qtd],
            descricao: it[:descricao]
          )
          itens_saved += 1
        end

        last_op = operacao
      end
    end

    { ops_updated_or_created: ops_saved, itens_created: itens_saved }
  ensure
    FileUtils.rm_f(pdf_path) if pdf_path && File.exist?(pdf_path)
  end

  private

  # ------------------------
  # Download
  # ------------------------
  def download_pdf!(url)
    tmp = Tempfile.new(["op_import_", ".pdf"], binmode: true)
    tmp.close

    # Usando Faraday (simples)
    resp = Faraday.get(url)
    raise ImportError, "Falha ao baixar PDF: HTTP #{resp.status}" unless resp.success?
    File.binwrite(tmp.path, resp.body)

    tmp.path
  end

  # ------------------------
  # Extração por página (texto -> fallback OCR)
  # ------------------------
  def extract_pages_text(pdf_path)
    # 1) tenta poppler pdftotext (bem mais confiável que PDF::Reader nesses casos)
    pages = pdftotext_pages(pdf_path)
  
    # Se veio bom, retorna
    return pages if pages.any? { |t| !text_garbled?(t) }
  
    # 2) fallback: OCR em todas as páginas
    ocr_all_pages(pdf_path)
  end

  def pdftotext_pages(pdf_path)
    Dir.mktmpdir("op_pdftotext") do |dir|
      out_txt = File.join(dir, "out.txt")
  
      # -layout preserva melhor colunas/tabelas
      cmd = [
        "pdftotext",
        "-layout",
        "-enc", "UTF-8",
        pdf_path,
        out_txt
      ].map { |x| Shellwords.escape(x) }.join(" ")
  
      ok = system(cmd)
      return [] unless ok && File.exist?(out_txt)
  
      content = File.read(out_txt, encoding: "UTF-8")
      # pdftotext separa páginas com form feed \f
      pages = content.split("\f").map { |p| safe_string(p).strip }
      pages.reject!(&:empty?)
      pages
    end
  end

  def text_garbled?(text)
    t = text.to_s.strip
    return true if t.length < 40
  
    # se tiver “muitos” caracteres fora do padrão, considera ruim
    weird = t.each_char.count { |c| c.ord < 9 || (c.ord > 126 && c.ord < 160) }
    ratio = weird.to_f / [t.length, 1].max
  
    ratio > 0.02
  end

  def safe_string(str)
    str.to_s.encode("UTF-8", invalid: :replace, undef: :replace, replace: " ")
  end

  def ocr_all_pages(pdf_path)
    # Converte tudo em PNG e roda tesseract em cada imagem
    Dir.mktmpdir("op_pdf_ocr") do |dir|
      convert_pdf_to_png!(pdf_path, dir)
      pngs = Dir["#{dir}/page-*.png"].sort

      pngs.map { |png| tesseract(png) }
    end
  end

  def convert_pdf_to_png!(pdf_path, dir)
    cmd = [
      "pdftoppm",
      "-png",
      pdf_path,
      "#{dir}/page"
    ].map { |x| Shellwords.escape(x) }.join(" ")

    ok = system(cmd)
    raise ImportError, "Falha ao converter PDF para PNG (pdftoppm)." unless ok
  end

  def tesseract(image_path)
    # -l por => OCR PT-BR (instale o idioma se necessário)
    out = `tesseract #{Shellwords.escape(image_path)} stdout -l por 2>/dev/null`
    safe_string(out)
  end
end

# ------------------------
# Parsers
# ------------------------
module HeaderParser
  module_function

  # Retorna:
  # { op_n:, pedido_venda:, quantidade:, observacoes: }
  def parse(text)
    normalized = normalize(text)

    {
      op_n:         extract_op(normalized),
      pedido_venda: extract_pedido_venda(normalized),
      quantidade:   extract_quantidade(normalized),
      observacoes:  extract_observacoes(normalized)
    }
  end

  def normalize(text)
    text.to_s
        .gsub("\u00A0", " ")
        .gsub(/[ \t]+/, " ")
        .gsub(/\r\n?/, "\n")
  end

  # No seu PDF aparece como "PCP Nº 8181" (ou equivalente)
  def extract_op(t)
    # tenta PCP
    val = t[/\bPCP\s*(?:N[ºo°]\s*)?(\d{3,})\b/i, 1]
    return val if val.present?

    # tenta OP
    t[/\bOP\s*(?:N[ºo°]\s*)?(\d{3,})\b/i, 1]
  end

  def extract_pedido_venda(t)
    t[/\bPEDIDO\s*VENDA\b[:\s]*([0-9]{3,})/i, 1]
  end

  def extract_quantidade(t)
    raw = t[/\bQUANTIDADE\b[:\s]*([0-9]+(?:[.,][0-9]+)?)/i, 1]
    return nil if raw.blank?

    raw.tr(",", ".").to_f
  end

  def extract_observacoes(t)
    # pega do "OBSERVAÇÕES" até antes de "ASSINATURA" / "MOD. ENTREGA" / etc
    m = t.match(/OBSERVA(?:C|Ç)OES?\b[:\s]*\n?(.*?)(?:\n(?:ASSINATURA|MOD\.\s*ENTREGA|ESTOQUE|PRODUCAO|FIM)\b|$)/im)
    return nil unless m

    obs = m[1].to_s.strip
    obs.presence
  end
end

module ItemTableParser
  module_function

  # Retorna array de { qtd:, descricao: }
  def parse(text)
    lines = normalize(text).split("\n").map(&:strip).reject(&:empty?)

    # Tenta achar onde começa a tabela (cabeçalho)
    start_idx = lines.find_index { |l| l.upcase.include?("DESCRI") && l.upcase.include?("QTD") }
    # se não achar, tenta parsear mesmo assim
    candidate_lines = start_idx ? lines[(start_idx + 1)..] : lines

    items = []
    candidate_lines.each do |line|
      break if line =~ /\bOBSERVA(?:C|Ç)OES?\b/i

      # Padrão típico:
      # "1 2 50015 - ACUCAR ... 500GR PC - PACOTE 0.400"
      # ou "1 2 ACUCAR ... PC - PACOTE ..."
      #
      # Captura:
      #   item_n (ignorado), qtd, descricao (até antes de duas ou mais espaços, ou antes de "PC", "UN", etc)
      #
      m = line.match(/^\s*(\d+)\s+(\d+(?:[.,]\d+)?)\s+(.+?)\s{2,}|\s*(\d+)\s+(\d+(?:[.,]\d+)?)\s+(.+)$/)
      next unless m

      qtd = (m[2] || m[5]).to_s.tr(",", ".").to_f
      desc = (m[3] || m[6]).to_s.strip

      # “limpa” o rastro de colunas do final, se vier tudo na mesma linha
      desc = desc.sub(/\s+(PC|UN|CX|PT|LT|FD|SC)\b.*$/i, "").strip

      next if desc.blank? || qtd <= 0

      items << { qtd: qtd, descricao: desc }
    end

    items
  end

  def normalize(text)
    text.to_s
        .gsub("\u00A0", " ")
        .gsub(/[ \t]+/, " ")
        .gsub(/\r\n?/, "\n")
  end
end