# Como instalar e configurar o sistema DSpace

## Instalação das dependências

```bash
$ sudo apt-get install tomcat7 postgresql postgresql-contrib openjdk-8-jdk maven ant
```

---

## Criação do usuário

Não é recomendado instalar o sistema DSpace no usuário `root`, e sim criar um usuário próprio. Para criar esse novo usuário, utilize o comando:
```bash
$ adduser dspace --ingroup tomcat7
```

* Para não permitir o login desse usuário na tela de login, utilize a  opção `-u` e use um UID menor que 1000. Ex.:
```bash
$ adduser dspace --ingroup tomcat7 -u 999
```

* Para logar no usuário recém criado, utilize:
```bash
$ sudo su - dspace
```

* Caso seja necessário voltar para o usuário root, utilize:
```bash
$ exit
```

---

## Download do código-fonte

No usuário `dspace`:

* **Opção 1)** Utilizando o Git:
```bash
$ git clone https://github.com/DSpace/DSpace.git
```

    * Caso queira usar uma versão específica:

        ```bash
$ git checkout dspace-5.5
        ```

* **Opção 2)** Diretamente pela página Git do projeto. Basta entrar na página, fazer o download e descompactar o pacote baixado.

---

## Criação e configuração do banco de dados

* Para executar os comandos a seguir é necessário a senha do usuário `postgres`. Caso não saiba qual é a senha, execute os comandos abaixo para reconfigurar a senha.
```bash
$ sudo service postgresql start
$ sudo su - postgres
$ psql -­c "ALTER USER postgres WITH PASSWORD '[SENHA]' ;"
```

* Para criar o usuário e o banco de dados no Postgres execute os seguintes comandos:
```bash
$ createuser -h localhost -U postgres --no-superuser --pwprompt [USUARIO_BD]
$ createdb -h localhost -U postgres -O [USUARIO_BD] [NOME_BD]
```

* Para o DSpace 6 ou posterior é preciso habilitar a extenão *pgcrypto* no banco de dados:
```bash
$ psql -h localhost -U postgres -d [NOME_BD] -c "CREATE EXTENSION pgcrypto;"
```

---

## Configuração dos parâmetros de compilação e execução do sistema

No usuário `dspace`:

* As principais configurações do DSpace, como o diretório de instalação, URL e informações do banco de dados, estão em:

  * No DSpace 5 ou inferior: `[DIR_SRC]/build.properties`. As alterações devem ser feitas diretamente nesse arquivo.

  * No Dspace 6 ou superior: `[DIR_SRC]/local.cfg.EXAMPLE`. Copie esse arquivo para `[DIR_SRC]/local.cfg` e faça as alterações nesse novo arquivo.


* As configurações mais importantes são:

    * Diretório onde o DSpace será instalado:

        ```bash
dspace.install.dir = [DIR_INSTALACAO]
        ```

    * Informações sobre o banco de dados:

        ```bash
db.url=jdbc:postgresql://localhost:5432/[NOME_BD]
db.username=[USUARIO_BD]
db.password=[SENHA_USUARIO_BD]
        ```

---

## Compilação do sistema

No usuário `dspace`:

* Antes da primeira execução do sistema, execute o seguinte comando para limpar arquivos temporários antigos e evitar erros:
```bash
$ mvn clean
```

* Para compilar o sistema, execute o comando a seguir na raiz do codigo-fonte do projeto:
```bash
$ mvn package
```

    * Alguns pacotes do DSpace podem não ser úteis em alguns casos. Caso deseje ignorá-los durante a compilação, basta usar a opção “-P” passando como parâmetro os nomes dos pacotes antecedidos por "!". Ex.:

        ```
$ mvn package -P "!dspace-lni, !dspace-sword, !dspace-swordv2, !dspace-jspui, !dspace-rdf"
        ```

* Para instalar o sistema, execute os comandos a seguir. Durante essa instalação serão criadas as tabelas no banco de dados e o diretório de instalação contendo todos os arquivos necessários para a execução do Dspace.
```bash
$ cd [DIR_SRC]/dspace/target/dspace-installer
$ ant fresh_install
```

* Para atualizar o sistema, execute novamente o comando para compilar o sistema e depois, no lugar da opção `fresh_install` utilizada no passo de instalação, utilize a opção `update`. Isso irá atualizar os webapps, configurações do diretório [DIR_INSTALACAO] e fazer as migrações do banco de dados, e não irá alterar nada do que está armazenado no sistema.
```bash
$ cd [DIR_SRC]/dspace/target/dspace-installer
$ ant update
```

---

## Instalação do sistema

* Configurar o Tomcat7 para ser executado no usuário `dspace` para evitar problemas de conflito de permissões dos arquivos entre o usuário `tomcat7` e `dspace`. Para isso, altere o parâmetro `TOMCAT7_USER` de `tomcat7` para `dspace` no arquivo `/etc/default/tomcat7`.
```text
TOMCAT7_USER=dspace
```

* Alterar a permissão dos diretórios de trabalho do Tomcat7, executando os seguintes comandos como `root`:
```bash
$ chown -R dspace:tomcat7 /var/log/tomcat7
$ chown -R dspace:tomcat7 /var/lib/tomcat7
$ chown -R dspace:tomcat7 /var/cache/tomcat7
```

* Configuração do diretório base dos webapps utilizados pelo Tomcat7:

    * **Opção 1)** Utilizar o diretório de webapps criados durante a instalação do DSpace. Para isso, no arquivo `/etc/tomcat7/server.xml`, altere o parâmetro `appBase` do campo `<Host>` para `[DIR_INSTALACAO]/webapps`:

        ```xml
<Host name="localhost" appBase="[DIR_INSTALACAO]/webapps"
unpackWARs="true" autoDeploy="true">
        ```

        * Obs.: Esse diretório é atualizado automaticamente após uma atualização do DSpace.

    * **Opção 2)** Utilizar o diretório padrão de webapps do Tomcat7. Para isso, copie os diretórios existentes no diretório `[DIR_INSTALACAO]/webapps` para `/var/lib/tomcat7/webapps`:

        ```bash
rsync --checksum --delete-delay --recursive [DIR_INSTALACAO]/webapps/* /var/lib/tomcat7/webapps/
        ```

        * Obs.: Esse mesmo comando pode ser usado para atualizar os webapps após uma atualização do DSpace, sem que seja necessário deletar e copiar novamente todos os webapps.

* Configurar o tomcat para usar criptografia SSL/HTTPS

    * Criar uma chave RSA

        ```bash
$ keytool -genkey -alias tomcat -keyalg RSA -keystor [CAMINHO_CHAVE]
        ```

    * No arquivo `/var/lib/tomcat7/conf/server.xml`, adicionar os parâmetros `keystoreFile` e `keystorePass` no campo `<Connector port=8443>`:

        ```xml
<Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true" maxThreads="150"
scheme="https" secure="true" clientAuth="false" sslProtocol="TLS"
keystoreFile="[ARQUIVO_KEYSTORE]" keystorePass="[SENHA]" />
        ```

* Para evitar problema de falta de memória durante a execução do DSpace, adicione ao arquivo `/usr/share/tomcat7/bin/setenv.sh` as seguintes linhas:

    ```bash
#!/bin/bash
export CATALINA_OPTS="$CATALINA_OPTS -Xms2048m -Xmx2g"
    ```

---

## Testando o sistema

* Abrir a página do sistema no navegador, acessando o link:
[http://localhost:8080/xmlui](http://localhost:8080/xmlui)

---

## Extras

* Para agilizar os passos de criar o usuário e banco de dados no PostgreSQL, foi criado dois scripts `create_pqsl_user.sh` e `create_pqsl_db.sh` que executam, respectivamente, essas tarefas. Para executá-los utilize os comandos abaixo:
```bash
$ ./create_pqsl_user.sh [USER_NAME]
$ ./create_psql_db.sh [USER_NAME] [DATABASE_NAME]
```

* Para agilizar os passos de compilação, instalação, atualização e deploy dos webapps foi criado um arquivo `Makefile`.

    * Primeiramente, copie o arquivo `Makefile` para o diretório [DIR_SRC].

    * Depois abra-o para edição e altere os seguintes parâmetros:

        * `DSPACE_WEBAPPS_FOLDER` : Diretório onde os webapps do DSpace são instalados (`[DIR_INSTALACAO]/webapps`).

        * `MIRAGE2_FLAG` : `true` para instalar o tema Mirage2, `false` para não instalar

    * Execute os seguintes comandos, dentro do diretório [DIR_SRC], para executar as tarefas correspondentes:

        * Para compilar:

            ```bash
$ make
            ```

        * Para instalar:

            ```bash
$ make install
            ```

        * Para atualizar:

            ```bash
$ make update
            ```

        * Para fazer o deploys (copiar os webapps para o diretório de webapps padrão do Tomcat7):

            ```bash
$ make deploy
            ```

        * Para limpar os arquivos temporários criados durante a compilação:

            ```bash
$ make clean
            ```
