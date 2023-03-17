# stone_pay_helper


Para funcionamento é necessário adicionar na pasta do projeto 

android/app/build.gradle:

a seguintes linhas:

    packagingOptions {
        exclude 'META-INF/api_release.kotlin_module'
        exclude 'META-INF/client_release.kotlin_module'
    }



## Utilização

Tantos métodos de payment e printer tem funções de callback. Ou seja as respostas vindas da maquininha serão mostradas nessa área

### Printer
No caso da impressora, será importante colocar uma StreamSubscription, e escutar as repostas por ele:

```
subscription = StonePayHelper.printerStreamListen.listen((String printerCallback) {
  print("===== CALLBACK $printerCallback =======");
  SchedulerBinding.instance.addPostFrameCallback((_) {
    if (printerCallback.contains("error")) {
      if (printerCallback.contains("PRINTER_OUT_OF_PAPER_ERROR")) {
        print("sem papel");
      }
      setState(() {
        print("erro");
        successPrint = false;
      });
    }
  });
});
```

Chamando a impressão por 2 métodos:

Passa base64 image para impressora:

```await StonePayHelper.printBase64(imgNota);```

Passa texto:

```await StonePayHelper.printBase64(imgString);```


Tipos de retorno possíveis nos erros do listener:

- PRINTER_PRINT_ERROR
- PRINTER_BUSY_ERROR
- PRINTER_INIT_ERROR
- PRINTER_LOW_ENERGY_ERROR
- PRINTER_OUT_OF_PAPER_ERROR
- PRINTER_UNSUPPORTED_FORMAT_ERROR