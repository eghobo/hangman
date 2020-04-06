to run: ``ruby hangman.rb``

create: ``curl -i -X POST -H "Content-Type: application/json" -d '{}' http://localhost:4567/hangman/api/v1/games`` 

get: ``curl -i -X GET -H "Content-Type: application/json" http://localhost:4567/hangman/api/v1/games/36ac0a02-b7a2-439d-83a7-dd149f7ae473``

turn: ``curl -i -X PATCH -H "Content-Type: application/json" -d '{"letter": "a"}' http://localhost:4567/hangman/api/v1/games/36ac0a02-b7a2-439d-83a7-dd149f7ae473``

stop: ``curl -i -X DELETE -H "Content-Type: application/json" http://localhost:4567/hangman/api/v1/games/36ac0a02-b7a2-439d-83a7-dd149f7ae473``