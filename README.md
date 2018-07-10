# Bank guarantee v2.0
# Production guide
  
 Metamask имеет требования в своем использование.
 Он не работает с простыми .html файлами в браузере, 
 то есть file:// в браузерной строке - и мы уже не
 можем его использовать. Для тестирования и применения
 можете использовать простой Java-сервер, идущий в комплекте со
 всей клиентской частью.
 
 Для запуска:
 1. Скомпилируйте и задеплойте два контракта из папки contracts, 
 указав при этом в поле whitelist_address контракта BankGuarantee адрес 
 только что скомпилированного Whitelist.
 2. В двух js файлах поменяйте адреса контрактов на ваши.
 3. Запустите сервер командой java -jar servWeb3.jar из папки со всеми клиентскими файлами.
 4. По адресу localhost:8000/bank.html и localhost:8000/user.html
 будут html обертки контрактов.
 
 Для более подробного описания устройства работы смотрите wiki проекта
