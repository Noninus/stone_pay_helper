# stone_pay_helper


Para funcionamento é necessário adicionar na pasta do projeto 

android/app/build.gradle:

a seguintes linhas:

    packagingOptions {
        exclude 'META-INF/api_release.kotlin_module'
        exclude 'META-INF/client_release.kotlin_module'
    }