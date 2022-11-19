import 'dart:io';

import 'package:caching_data/employees_model.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dio and Cache'),
      ),
      body: FutureBuilder(
        future: EmployeesController.getAllEmployees(),
        builder: (context, AsyncSnapshot<List<Data>?> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index].employeeName!),
                    subtitle: Text(snapshot.data![index].employeeAge!.toString()),
                    trailing: Text(snapshot.data![index].employeeSalary.toString()),
                  );
                },
              );
            } else {
              return Text('No Data Found');
            }
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return Center(child: const CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class EmployeesController {
  static Future<List<Data>?> getAllEmployees() async {
    String url = 'http://dummy.restapiexample.com/api/v1/employees';
    List<Data> result = [];
    try {
      Dio dio = Dio();
      DioCacheManager dioCacheManager = DioCacheManager(CacheConfig());
      // forceRefresh => if internet avalible fetch data from url , if not fetch data from device
      Options myOptions =
          buildCacheOptions(const Duration(days: 30), forceRefresh: true);
      dio.interceptors.add(dioCacheManager.interceptor);

      var res = await dio.get(url, options: myOptions);
      result = getList(res.data);
    } catch (e) {
      if (e is SocketException) {
        return null;
      }
    }
    return result;
  }

  static getList(body) {
    List<Data> emp = [];
    List x = (body)['data'];
    x.forEach((element) {
      emp.add(Data.fromJson(element));
    });
    return emp;
  }
}
