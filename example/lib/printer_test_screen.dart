import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:stone_pay_helper/stone_pay_helper.dart';
import 'package:stone_pay_helper_example/img_nota.dart';
import 'package:stone_pay_helper_example/img_string.dart';
import 'package:stone_pay_helper_example/img_string_ja_convertida.dart';

class PrinterTestScreen extends StatefulWidget {
  @override
  _PrinterTestScreenState createState() => _PrinterTestScreenState();
}

class _PrinterTestScreenState extends State<PrinterTestScreen> {
  StreamSubscription? subscription;
  bool successPrint = true;
  final globalScaffoldKey = GlobalKey<ScaffoldMessengerState>();
  @override
  void initState() {
    super.initState();
    subscription =
        StonePayHelper.printerStreamListen.listen((String printerCallback) {
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
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  Future<void> printBase64() async {
    try {
      await StonePayHelper.printBase64(imgNota);
    } on PlatformException {
      print('Failed to get platform version.');
    }
    if (!mounted) return;
  }

  Future<void> printBase64PreConta() async {
    try {
      await StonePayHelper.printBase64(imgString);
    } on PlatformException {
      print('Failed to get platform version.');
    }
    if (!mounted) return;
  }

  Future<void> printBase64JaConvertidaPreConta() async {
    try {
      await StonePayHelper.printBase64(imgJaConvertida380);
    } on PlatformException {
      print('Failed to get platform version.');
    }
    if (!mounted) return;
  }

  Future<void> printText() async {
    try {
      await StonePayHelper.printText(
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum");
    } on PlatformException {
      print('Failed to get platform version.');
    }
    if (!mounted) return;
  }

  Future<void> printPreContaStone({
    required String mesa,
    required List<Map<String, dynamic>> itens,
    required double valorTotal,
    required int numeroPessoas,
    String nomeEstabelecimento = "Squalus",
    String telefone = "(43) 99996-2360 3338-8099",
    bool showFeedback = false,
  }) async {
    setState(() {
      successPrint = true;
    });

    try {
      // Calcula valor por pessoa
      double valorPorPessoa = valorTotal / numeroPessoas;

      // Formata data e hora
      DateTime agora = DateTime.now();
      String dataHora =
          "${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year.toString().substring(2)} Abert: ${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')} Fech:${agora.hour.toString().padLeft(2, '0')}:${agora.minute.toString().padLeft(2, '0')}";

      // Monta o cabeçalho da tabela
      String cabecalhoTabela = "Q de       Descrição       Vl Unit  Sub-To";

      List<Map<String, dynamic>> printData = [
        {
          "type": "text",
          "content":
              "Conferência de Conta\n================================================\nAGUARDE A EMISSÃO DA NOTA FISCAL\n================================================",
          "align": "center",
          "size": "small"
        },
        {
          "type": "text",
          "content": "Data: $dataHora\n\nMesa: $mesa\n\n$cabecalhoTabela",
          "align": "left",
          "size": "small"
        },
      ];

      // Adiciona itens com formatação melhorada
      for (var item in itens) {
        int qtd = item['quantidade'];
        String descricao = item['descricao'].toString();
        double vlUnit = item['valorUnitario'];
        double subTotal = item['subTotal'];

        // Formata para ficar alinhado como na imagem
        // Formato: "1 Sprite Lata                5,00    5,0"
        String linha =
            "${qtd.toString().padRight(2)} ${descricao.padRight(23)} ${vlUnit.toStringAsFixed(2).replaceAll('.', ',').padLeft(5)} ${subTotal.toStringAsFixed(2).replaceAll('.', ',')}";

        printData.add({
          "type": "text",
          "content": linha,
          "align": "left",
          "size": "small"
        });
      }

      // Adiciona linhas pontilhadas e totais (agrupados para reduzir padding)
      printData.addAll([
        {
          "type": "text",
          "content":
              "------------------------------------------------\nValor a Pagar: ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}\nValor por Pessoa: ($numeroPessoas pessoa${numeroPessoas > 1 ? 's' : ''})\n${valorPorPessoa.toStringAsFixed(2).replaceAll('.', ',')}\n------------------------------------------------\n$nomeEstabelecimento\nFone $telefone\n================================================\nAGUARDE A EMISSÃO DA NOTA FISCAL\nSem Valor Fiscal / Peça Nota Fiscal",
          "align": "center",
          "size": "small"
        },
      ]);

      String printingData = printData
          .map((e) => e
              .toString()
              .replaceAll('{', '{"')
              .replaceAll(':', '":')
              .replaceAll(', ', ', "'))
          .join(',\n');

      // Converte para JSON válido
      printingData = "[${printData.map((item) {
        String type = item['type'];
        String content = item['content'].toString().replaceAll('"', '\\"');
        String align = item['align'] ?? '';
        String size = item['size'] ?? '';

        if (type == 'line') {
          return '{"type": "line", "content": "$content"}';
        } else {
          return '{"type": "$type", "content": "$content", "align": "$align", "size": "$size"}';
        }
      }).join(',\n')}]";

      print("Iniciando impressão de pré-conta via DeepLink...");
      final String result = await StonePayHelper.sendDeepLinkPrinter(
        printingData: printingData,
        returnScheme: "flutterdeeplinkdemo",
        showFeedbackScreen: showFeedback,
      );

      print("Resultado da impressão: $result");

      if (result == "SUCCESS") {
        setState(() {
          successPrint = true;
        });
        globalScaffoldKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("Pré-conta impressa com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          successPrint = false;
        });

        String errorMessage = "Erro na impressão: ";
        switch (result) {
          case "PRINTER_OUT_OF_PAPER":
            errorMessage += "Sem papel na impressora";
            break;
          case "PRINTER_INIT_ERROR":
            errorMessage += "Erro ao inicializar impressora";
            break;
          case "LOW_ENERGY":
            errorMessage += "Bateria baixa";
            break;
          case "PRINTER_BUSY":
            errorMessage += "Impressora ocupada";
            break;
          case "PRINTER_COVER_OPEN":
            errorMessage += "Tampa da impressora aberta";
            break;
          default:
            errorMessage += result;
        }

        globalScaffoldKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao imprimir pré-conta: $e');
      setState(() {
        successPrint = false;
      });
      globalScaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Erro ao imprimir pré-conta: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> printDeepLink({bool showFeedback = false}) async {
    setState(() {
      successPrint = true; // Reset status
    });

    try {
      // Exemplo de conteúdo JSON para impressão
      String printingData = """
[
  {
    "type": "text",
    "content": "TESTE DEEPLINK IMPRESSORA",
    "align": "center",
    "size": "big"
  },
  {
    "type": "text",
    "content": "Data: ${DateTime.now().toString().substring(0, 19)}",
    "align": "right",
    "size": "medium"
  },
  {
    "type": "text",
    "content": "Feedback Screen: $showFeedback",
    "align": "left",
    "size": "small"
  },
  {
    "type": "line",
    "content": "========================"
  },
  {
    "type": "text",
    "content": "ITENS DO PEDIDO",
    "align": "center",
    "size": "medium"
  },
  {
    "type": "text",
    "content": "1x Produto Teste - R\$ 10,00",
    "align": "left",
    "size": "small"
  },
  {
    "type": "text",
    "content": "2x Outro Produto - R\$ 25,00",
    "align": "left",
    "size": "small"
  },
  {
    "type": "line",
    "content": "========================"
  },
  {
    "type": "text",
    "content": "TOTAL: R\$ 60,00",
    "align": "right",
    "size": "big"
  },
  {
    "type": "text",
    "content": "Obrigado pela compra!",
    "align": "center",
    "size": "medium"
  }
]
      """;

      print("Iniciando impressão via DeepLink...");
      final String result = await StonePayHelper.sendDeepLinkPrinter(
        printingData: printingData,
        returnScheme: "flutterdeeplinkdemo",
        showFeedbackScreen: showFeedback,
      );

      print("Resultado da impressão: $result");

      // Verifica o resultado e atualiza o estado
      if (result == "SUCCESS") {
        setState(() {
          successPrint = true;
        });
        globalScaffoldKey.currentState?.showSnackBar(
          SnackBar(
            content: Text("Impressão concluída com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          successPrint = false;
        });

        // Mensagens específicas para cada tipo de erro
        String errorMessage = "Erro na impressão: ";
        switch (result) {
          case "PRINTER_OUT_OF_PAPER":
            errorMessage += "Sem papel na impressora";
            break;
          case "PRINTER_INIT_ERROR":
            errorMessage += "Erro ao inicializar impressora";
            break;
          case "LOW_ENERGY":
            errorMessage += "Bateria baixa";
            break;
          case "PRINTER_BUSY":
            errorMessage += "Impressora ocupada";
            break;
          case "PRINTER_COVER_OPEN":
            errorMessage += "Tampa da impressora aberta";
            break;
          default:
            errorMessage += result;
        }

        globalScaffoldKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao enviar deeplink: $e');
      setState(() {
        successPrint = false;
      });
      globalScaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Erro ao enviar comando de impressão: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: globalScaffoldKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  printBase64();
                },
                child: Text("printBase64")),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  printText();
                },
                child: Text("printText")),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  printBase64PreConta();
                },
                child: Text("print pre conta convertida por flutter")),
            ElevatedButton(
                onPressed: () {
                  printBase64JaConvertidaPreConta();
                },
                child: Text("printBase64JaConvertidaPreContaSemFlutter")),
            SizedBox(
              height: 10,
            ),
            Divider(thickness: 2),
            Text(
              "TESTE DEEPLINK IMPRESSORA",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  printDeepLink(showFeedback: false);
                },
                child: Text("Print DeepLink SEM Feedback")),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  printDeepLink(showFeedback: true);
                },
                child: Text("Print DeepLink COM Feedback")),
            SizedBox(
              height: 10,
            ),
            Divider(thickness: 2),
            Text(
              "PRÉ-CONTA STONE",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  // Exemplo de uso com dados de teste
                  printPreContaStone(
                    mesa: "33",
                    itens: [
                      {
                        'quantidade': 1,
                        'descricao': 'Sprite Lata',
                        'valorUnitario': 5.00,
                        'subTotal': 5.00,
                      },
                    ],
                    valorTotal: 5.00,
                    numeroPessoas: 2,
                    nomeEstabelecimento: "Squalus",
                    telefone: "(43) 99996-2360 3338-8099",
                    showFeedback: false,
                  );
                },
                child: Text("Imprimir Pré-Conta (Exemplo)")),
            SizedBox(
              height: 20,
            ),
            successPrint
                ? Icon(Icons.check_circle_outline,
                    color: Colors.green, size: 50)
                : Icon(Icons.error, color: Colors.red, size: 50)
          ],
        ),
      ),
    );
  }
}
