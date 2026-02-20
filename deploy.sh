echo "=== Mensagem de commit ==="
read commit_message

git add .
git commit -am "$commit_message"
git pull
git push

git pull heroku main
git push heroku main

