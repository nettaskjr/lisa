# Lisa
Lisa é um sistema de backup que utiliza o rsync como principal forma de backup e sincronismo 'Origem/Destino'.

Criada especialmente para fazer backups 'localmente' em dispositivos removiveis ou não, Pendrives, HD, HD Externo.
A Lisa não utiliza os nomes de dispositivos, exemplo (/dev/sdb) (/dev/sdc) ao invés disto é utilizado o UUID do dispositivo.
Com a informação do UUID do dispositivo fica menos sucessivel a falhas. Existem vários problemas relacionados principalmente com HD's Externo, as vezes montamos como /dev/sdb por exemplo, e ao desmontar é trocado para /dev/sdc, com isto é gerado uma falha no backup, prefira indiciar o UUID.
O UUID do hd será gravado na primeira execução do script caso queira alterar o UUID, apague o arquivo hd que está na raiz, e execute novamente o script, ou altere a informação neste mesmo arquivo.
Ao iniciar o script, caso seja a primeira vez, será solicitado o UID do dispositivo a ser utilizado.
Será informado as partiçoes montadas, para facilitar a localização do UID.
