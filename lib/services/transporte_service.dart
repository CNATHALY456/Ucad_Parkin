import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class TransporteService {
  // 🔍 READ
  Future<List<dynamic>> obtener() async {
    return await supabase.from('transporte').select();
  }

  // ➕ CREATE
  Future insertar(Map<String, dynamic> data) async {
    await supabase.from('transporte').insert(data);
  }

  // ✏️ UPDATE
  Future actualizar(String id, Map<String, dynamic> data) async {
    await supabase.from('transporte').update(data).eq('id', id);
  }

  // ❌ DELETE
  Future eliminar(String id) async {
    await supabase.from('transporte').delete().eq('id', id);
  }
}
