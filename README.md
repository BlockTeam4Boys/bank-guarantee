# Bank guarantee

Полноценно работает в браузерах: Firefox ...

Для полноценной работы с ropsten'ом необходимо:

  1. Поднятая нода на localhost'е. Достаточно запустить geth с указанными ключами 
  sudo geth --testnet --syncmode="light" --rpc --rpcapi db,eth,net,web3,personal --cache=1024 --rpcport 8545 --rpcaddr 127.0.0.1 --rpccorsdomain "*" console 2>>geth.log 
  
  2. Создать новый аккаунт : personal.newAccount("prettyPassword") - в дальнейшем данный аккаунт 
  будет иметь статус банка в смарт-контракте
  
  3. Пополнить его баланс
  
  4. Задеплоить контракт с недавно созданного аккаунта.
  // сохранить адрес контракта в html ?? 
  
  В итоге можно запускать веб-интерфейс
