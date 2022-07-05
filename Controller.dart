//@author Gustavo Matos Lázaro

//Todas as requisições nesse método NÃO É A ÚNICA MANEIRA DE FAZER
//Porém, é a maneira que nós escolhemos fazer, e O PADRÃO DEVE SER SEGUIDO.

import 'package:flutter/material.dart'; //Importe do Material
import 'package:http/http.dart' as http; //Importe do http (biblioteca usada para fazer as requisiçoes HTTP - https://pub.dev/packages/http)
import 'dart:convert';

// Por conveção NOSSA, as requisições sempre ficam no Controller
class controller {

  static final bool DEV = true; //Variavel que define se o projeto ainda está em desenvolvimento
  static String url = 'http://192.168.15.19:8080/Contexto/'; //IP do Back-end
  static int resquestDurationSecondsTime = DEV ? 360 : 30; //Variavel de tempo limite das requisições

  //Por convenção, os metodos REST começam com o tipo da requisição e o nome. EX: (POST - LOGIN)


  //----------------- EXEMPLO MÉTODO HTTP GET -----------------


  //É uma função estática (Acessivel em todo o projeto), PODE SER do tipo Map futuro (Vai retornar um map), de nome XXX,
  //Que recebe por parametro XXX e que é assincrona (Por isso que é do tipo Future<Map>).
  static Future<Map> getCep(String cep) async { //É um REST GET, logo NÃO TEM BODY
    
    //Sempre use try catch
    try {

      //Variavel do tipo http.Response RECEBE (com await) a requisição REST que você quer (Nesse caso do tipo GET)
      http.Response response = await http.get(
        Uri.parse(url + 'app/getCep.json?cep=' + cep), //URL da API COM OS PARAMETROS - EX: (url ? parametro = valor do parametro & parametro2 = valor do parametro2)
        headers: { //Headers da requisição
          "Content-Type": "application/json",
          "Authorization": usuarioLogado.token.toString()
        },

      //Controle de timeout - Como é um método assincrono, ele vai parar o código
      //até receber um retorno. Caso o retorono não venha em um tempo X
      //(Neste caso definido pela variável resquestDurationSecondsTime),
      //ele cancela a requisição anterior e retorna um erro.  
      ).timeout(
          Duration(seconds: resquestDurationSecondsTime),
          onTimeout: () => http.Response(
            'timeout',
            408,
          )
      );

      //Variável do tipo Map que recebe a resposta da API. O retorno da api
      //vem um bytes, logo precisa ser decodificada em um JSON
      Map jsonData = json.decode(response.body);

      //Print opcional de debug
      debugPrint('getCep: ' + jsonData.toString());

      //Se o campo "success" do Map da variável definida a cima tiver o valor "true"
      //Então a requisição deu certo
      if (jsonData['success'].toString() == 'true') {
        
        return jsonData; //NESTE CASO retorna um map (Pq a função é do tipo Future<Map>)

      } else {  //Se o campo "success" do Map da variável definida a cima tiver o valor DIFERENTE DE "true"
        
        //Retorna um Map de false
        return {
          'success': 'false',
          'message': jsonData['message'].toString(),
        };
      }

    //Caso dê algum erro dentro do try (Valores nulos causam erro), ele cai aq no catch
    } catch (error) {

      debugPrint('erro getCep: ' + error.toString()); //Printa o erro

      //Retorna um Map de catch
      return {
        'success': 'catch',
        'message': 'Erro ao buscar dados. Tente novamente mais tarde.',
      };
    }
  }

  //----------------- EXEMPLO MÉTODO HTTP POST -----------------


  //É uma função estática (Acessivel em todo o projeto), PODE SER do tipo String futuro (Vai retornar uma string), de nome XXX,
  //Que recebe por parametro XXX e que é assincrona (Por isso que é do tipo Future<String>).
  static Future<String> postLogin(String login, String senha) async { //É uma função assincrona, pois ela precisa esperar um retorno da API para continuar

  //Como NESSE EXEMPLO é um POST (Tem body), é definido um body para enviar
    String mapToSend = '{' //O body é um JSON SEMPRE (No flutter, por convenção, é feito um tipo string no formato de um JSON)
        + '"login":"' + login + '",'
        + '"senha":"' + senha + '"'
        + '}';

    //Print de depuração OPCIONAL
    debugPrint('postLogin body ' + mapToSend.toString());

    //Começo da tentativa de requisição - SEMPRE USE TRY CATCH
    try {

      //Variavel do tipo http.Response RECEBE (com await) a requisição REST que você quer (Nesse caso do tipo POST)
      http.Response response = await http.post(
        Uri.parse(url + 'app/login.json'), //URL da requisição
        headers: { //Headers passado para requisição (Se tivesse um token de Autorização, passaria aq)
          "Content-Type": "application/json",
          // "Authorization": usuarioLogado.token.toString()
        },
        body: mapToSend, //Como é uma requisição POST, o body é passado (A variável que você montou no começo do método.)
        
      //Controle de timeout - Como é um método assincrono, ele vai parar o código
      //até receber um retorno. Caso o retorono não venha em um tempo X
      //(Neste caso definido pela variável resquestDurationSecondsTime),
      //ele cancela a requisição anterior e retorna um erro.  
      ).timeout(
          Duration(seconds: resquestDurationSecondsTime),
          onTimeout: () => http.Response(
            'timeout',
            408,
          )
      );

      //Prints OPCIONAIS de depuração
      debugPrint('postLogin URL-> ' + url + 'app/login.json' + '\n');
      debugPrint('postLogin CODE-> ' + response.statusCode.toString());
      debugPrint('postLogin response->' + response.body.toString());

      //Variável do tipo Map que recebe a resposta da API. O retorno da api
      //vem um bytes, logo precisa ser decodificada em um JSON
      Map jsonData = json.decode(response.body);

      //Se o campo "success" do Map da variável definida a cima tiver o valor "true"
      //Então a requisição deu certo
      if (jsonData['success'].toString() == 'true') {
        
        //Seu código se for true aq

        return 'true';

      } else { //Se o campo "success" do Map da variável definida a cima tiver o valor DIFERENTE DE "true"
        return jsonData['message'].toString();
      }

    //Caso dê algum erro dentro do try (Valores nulos causam erro), ele cai aq no catch
    } catch (error) {
      //Print de debug 
      debugPrint('erro postLogin: ' + error.toString());

      return 'catch'; //retorno
    }
  }

}
