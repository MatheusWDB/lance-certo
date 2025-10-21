mixin ValidationsMixin {
  String? isNotEmpty(String? value, [String? message]) {
    if (value!.isEmpty) return message ?? 'Campo obrigatório.';
    return null;
  }

  String? hasEightChars(String? value, [String? message]) {
    if (value!.length < 8) return message ?? 'A senha tem que ter no mínimo 8 caracteres.';
    return null;
  }

  String? isValidEmail(String? value, [String? message]) {
    if (!value!.contains('@') || !value.contains('.')) {
      final int atIndex = value.indexOf('@');
      final int dotIndex = value.lastIndexOf('.');

      if (atIndex < 1 ||
          dotIndex < atIndex + 2 ||
          dotIndex == value.length - 1) {
        return message ?? 'Formato de email inválido.';
      }
    }
    return null;
  }

  String? combine(List<String? Function()> validators, [String? message]) {
    for (var func in validators) {
      final validation = func();
      if (validation != null) return validation;
    }
    return null;
  }
}
