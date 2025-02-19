import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_m8/Widgets/widgets.dart';
import 'package:flutter_m8/components/components.dart';
import 'package:flutter_m8/services/service_sat.dart';
import 'package:path_provider/path_provider.dart';

class SatPage extends StatefulWidget {
  @override
  _SatPageState createState() => _SatPageState();
}

class _SatPageState extends State<SatPage> {
  SatService serviceSat = new SatService();

  TextEditingController inputCodeAtivacao =
      new TextEditingController(text: "123456789");

  String cfeCancelamento = "";
  String modelSAT = "SMART SAT";

  onChangeTypeSAT(String value) {
    setState(() {
      modelSAT = value;
    });
  }

  String resultSAT = "";

  sendAtivarSAT() async {
    if (isInputCodeAtivacaoEmpty()) {
      Components.infoDialog(
        context: context,
        message: "A entrada de Texto não pode estar vazia!",
      );
      return;
    }

    String result = await serviceSat.sendSatActive(
      subComando: 2,
      codeAtivacao: inputCodeAtivacao.text,
      cnpj: "14200166000166",
      cUF: 15,
    );
    formatResponseSAT(result);
  }

  sendAssociarSAT() async {
    if (isInputCodeAtivacaoEmpty()) {
      Components.infoDialog(
        context: context,
        message: "A entrada de Texto não pode estar vazia!",
      );
      return;
    }

    String result = await serviceSat.sendSatAssociar(
      codeAtivacao: inputCodeAtivacao.text,
      cnpjSh: "16716114000172",
      assinaturaAC: "SGR-SAT SISTEMA DE GESTAO E RETAGUARDA DO SAT",
    );
    formatResponseSAT(result);
  }

  sendConsultarSAT() async {
    if (isInputCodeAtivacaoEmpty()) {
      Components.infoDialog(
        context: context,
        message: "A entrada de Texto não pode estar vazia!",
      );
      return;
    }

    String result = await serviceSat.sendConsultarSAT();
    formatResponseSAT(result);
  }

  sendStatusOperacional() async {
    if (isInputCodeAtivacaoEmpty()) {
      Components.infoDialog(
        context: context,
        message: "A entrada de Texto não pode estar vazia!",
      );
      return;
    }

    String result = await serviceSat.sendStatusOperacionalSAT(
      codeAtivacao: inputCodeAtivacao.text,
    );
    formatResponseSAT(result);
  }

  sendEnviarVendasSAT() async {
    String xmlEnviaDadosVenda;

    if (isInputCodeAtivacaoEmpty()) {
      Components.infoDialog(
        context: context,
        message: "A entrada de Texto não pode estar vazia!",
      );
      return;
    }

    if (modelSAT == "SMART SAT") {
      xmlEnviaDadosVenda =
          await rootBundle.loadString('assets/xml/xmlEnviaDadosVendaSAT.xml');
    } else {
      xmlEnviaDadosVenda = await rootBundle.loadString('assets/xml/satGO3.xml');
    }

    String result = await serviceSat.sendEnviarVendaSAT(
      codeAtivacao: inputCodeAtivacao.text,
      xmlSale: xmlEnviaDadosVenda,
    );

    List<String> newResult = result.split("|");

    if (newResult.length > 8) {
      cfeCancelamento = newResult[8];
    }
    formatResponseSAT(result);
  }

  sendCancelarVendaSAT() async {
    String xmlCancelamento;

    if (isInputCodeAtivacaoEmpty()) {
      Components.infoDialog(
        context: context,
        message: "A entrada de Texto não pode estar vazia!",
      );
      return;
    }

    if (modelSAT == "SMART SAT") {
      xmlCancelamento = await rootBundle
          .loadString('assets/xml/xmlCancelarUltimaVendaSAT.xml');
    } else {
      xmlCancelamento =
          await rootBundle.loadString('assets/xml/cancelamentoSatGo.xml');
    }

    xmlCancelamento = xmlCancelamento.replaceAll("novoCFe", cfeCancelamento);

    String result = await serviceSat.sendCancelarVendaSAT(
      codeAtivacao: inputCodeAtivacao.text,
      xmlCancelamento: xmlCancelamento,
      cFeNumber: cfeCancelamento,
    );

    formatResponseSAT(result);
  }

  sendExtrairLog() async {
    if (isInputCodeAtivacaoEmpty()) {
      Components.infoDialog(
        context: context,
        message: "A entrada de Texto não pode estar vazia!",
      );
      return;
    }

    String result = await serviceSat.sendExtrairLogSAT(
      codeAtivacao: inputCodeAtivacao.text,
    );
    formatResponseSAT(result);
  }

  formatResponseSAT(String result) {
    var dt = DateTime.now();
    String dateFormat =
        "Data e Hora: ${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}:${dt.second}\n\n";

    setState(() {
      resultSAT = dateFormat +
          result +
          "\n" +
          "-----------------------------\n\n" +
          resultSAT;
    });
  }

  isInputCodeAtivacaoEmpty() {
    return inputCodeAtivacao.text.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(height: 30),
              GeneralWidgets.headerScreen("SAT Homologação"), 
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  boxScreen(),
                  SizedBox(width: 20),
                  buttons(),
                ],
              ),
              GeneralWidgets.baseboard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buttons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        typesModelsRadios(),
        SizedBox(height: 10),
        GeneralWidgets.inputField(
          inputCodeAtivacao,
          'Código ativação: ',
          textSize: 14,
          iWidht: 340,
          textInputType: TextInputType.number,
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Column(
              children: [
                GeneralWidgets.personButton(
                  textButton: "CONSULTAR SAT",
                  width: 170,
                  callback: sendConsultarSAT,
                ),
                SizedBox(height: 10),
                GeneralWidgets.personButton(
                  textButton: "STATUS OPERACIONAL",
                  width: 170,
                  callback: sendStatusOperacional,
                ),
                SizedBox(height: 10),
                GeneralWidgets.personButton(
                  textButton: "REALIZAR VENDA",
                  width: 170,
                  callback: sendEnviarVendasSAT,
                ),
              ],
            ),
            SizedBox(width: 10),
            Column(
              children: [
                GeneralWidgets.personButton(
                  textButton: "CANCELAMENTO",
                  width: 170,
                  callback: sendCancelarVendaSAT,
                ),
                SizedBox(height: 10),
                GeneralWidgets.personButton(
                  textButton: "ATIVAR",
                  width: 170,
                  callback: sendAtivarSAT,
                ),
                SizedBox(height: 10),
                GeneralWidgets.personButton(
                  textButton: "ASSOCIAR",
                  width: 170,
                  callback: sendAssociarSAT,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget boxScreen() {
    return Container(
      height: 370,
      width: 400,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("RETORNO:"),
            Container(
              height: 310,
              width: 500,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: SingleChildScrollView(child: Text(resultSAT)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget typesModelsRadios() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 160,
          child: GeneralWidgets.radioBtn(
            'SMART SAT',
            modelSAT,
            onChangeTypeSAT,
          ),
        ),
        GeneralWidgets.radioBtn(
          'SATGO',
          modelSAT,
          onChangeTypeSAT,
        ),
      ],
    );
  }
}
