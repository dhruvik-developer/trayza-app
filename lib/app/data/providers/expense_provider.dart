import 'package:dio/dio.dart';
import '../../core/utils/api_client.dart';

class ExpenseProvider {
  // Expense Categories
  Future<Response> getExpenseCategories() async {
    try {
      final response = await ApiClient.dio.get('/expenses-categories/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createExpenseCategory(String name) async {
    try {
      final response = await ApiClient.dio.post('/expenses-categories/', data: {'name': name});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteExpenseCategory(int id) async {
    try {
      final response = await ApiClient.dio.delete('/expenses-categories/$id/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Expenses
  Future<Response> getExpenses() async {
    try {
      final response = await ApiClient.dio.get('/expenses/');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createExpense(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.post('/expenses/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateExpense(int id, Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.dio.put('/expenses/$id/', data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteExpense(int id) async {
    try {
      final response = await ApiClient.dio.delete('/expenses/$id/');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
