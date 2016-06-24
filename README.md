# Como instalar e configurar o sistema DSpace

## Instalação das dependências

```bash
$ sudo apt-get install tomcat7 postgresql postgresql-contrib openjdk-8-jdk maven ant
```

### Criação do usuário

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

### Download do código-fonte

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


### Criação e configuração do banco de dados

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

### Configuração dos parâmetros de compilação e execução do sistema

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

### Compilação do sistema

No usuário `dspace`:

1. Antes da primeira execução do sistema, execute o seguinte comando para limpar arquivos temporários antigos e evitar erros:
```bash
$ mvn clean
```

2. Compilar o sistema, executando o comando a seguir na raiz do codigo-fonte do projeto:
```bash
$ mvn package
```

    * Alguns pacotes do DSpace podem não ser úteis em alguns casos. Caso deseje ignorá-los durante a compilação, basta usar a opção “-P” passando como parâmetro os nomes dos pacotes antecedidos por “!”. Ex.:
    
        ```bash
        $ mvn package -P “!dspace-lni, !dspace-sword, !dspace-swordv2, !dspace-jspui, !dspace-rdf”
        ```

3. Instalar o sistema, executando os comandos a seguir. Durante essa instalação serão criadas as tabelas no banco de dados configurado e o diretório de instalação contendo todos os arquivos necessários para a execução do Dspace.
```bash
$ cd [DIR_SRC]/dspace/target/dspace-installer
$ ant fresh_install
```

### Instalação do sistema

* No arquivo `/etc/tomcat7/server.xml`, alterar o parâmetro `appBase` do campo `<Host>` para `<DIR_INSTALACAO>/webapps`:

    ```xml
    <Host name="localhost" appBase="[DIR_INSTALACAO]/webapps"
    unpackWARs="true" autoDeploy="true">
    ```

* Configurar o tomcat para usar criptografia SSL/HTTPS

    * Criar uma chave RSA

        ```bash
        $ keytool -genkey -alias tomcat -keyalg RSA -keystore [CAMINHO_CHAVE]
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
    export CATALINA_OPTS="$CATALINA_OPTS -Xms1024m -Xmx2g"
    ```

### Testando o sistema

* Abrir a página do sistema no navegador, acessando o link:
[http://localhost:8080/xmlui](http://localhost:8080/xmlui)
