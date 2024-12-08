import 'package:flutter/material.dart';

class NuevaTareaScreen extends StatefulWidget {
  @override
  _NuevaTareaScreenState createState() => _NuevaTareaScreenState();
}

class _NuevaTareaScreenState extends State<NuevaTareaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controladorTarea = TextEditingController();

  @override
  void dispose() {
    _controladorTarea.dispose();
    super.dispose();
  }

  void _guardarTarea() {
    if (_formKey.currentState!.validate()) {
      final nuevaTarea = _controladorTarea.text;
      // Aquí podrías guardar la tarea en una base de datos local o en memoria
      // y luego regresar a la lista.
      Navigator.pop(context, nuevaTarea);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _controladorTarea,
                decoration: InputDecoration(
                  labelText: 'Nombre de la tarea',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre para la tarea';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarTarea,
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}