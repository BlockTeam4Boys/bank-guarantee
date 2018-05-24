# Bank guarantee

Работает без ошибок в браузере Firefox
Пример запуска под ropsten
Для полноценной работы необходимо:
  1. Поднять ноду на localhost'е. Достаточно запустить geth с указанными ключами 
  sudo geth --testnet --syncmode="light" --rpc --rpcapi db,eth,net,web3,personal --cache=1024 --rpcport 8545 --rpcaddr 127.0.0.1 --rpccorsdomain "*" console 2>>geth.log 
  
  2. Создать новый аккаунт : personal.newAccount("prettyPassword") - в дальнейшем данный аккаунт 
  будет иметь статус банка в смарт-контракте
  
  3. Разблокировать созданный аккаунт web3.personal.unlockAccount(web3.personal.listAccounts[0],"prettyPassword", 15000)
  
  3. Пополнить его баланс
  
  4. Задеплоить контракт с недавно созданного аккаунта.
  5. В поле address index.html указать адрес контракта
  
  В итоге можно запускать веб-интерфейс
  
  Для работы с мейн-нетом следует пропустить флаг --testnet
