import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class ReflectionFormatLint extends DartLintRule {
  static final _reflectionRegExp =
      RegExp(r'//+\s*REFLECTION\b', caseSensitive: false);

  static final RegExp _reflectionExpectedRegExp = RegExp(
    r'//\s*REFLECTION:\s+.+',
  );

  const ReflectionFormatLint() : super(code: _code);

  static const _code = LintCode(
    name: 'reflection_format',
    problemMessage:
        'REFLECTION comment must follow format: // REFLECTION: Reflection text',
  );

  @override
  void run(
    CustomLintResolver resolver,
    dynamic reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      _visitCompilationUnit(node, reporter, resolver);
    });
  }

  void _visitCompilationUnit(
      CompilationUnit node, reporter, CustomLintResolver resolver) {
    // Collect all comments from the compilation unit
    List<Token> allComments = [];
    Token? token = node.beginToken;

    while (token != null) {
      Token? comment = token.precedingComments;
      while (comment != null) {
        allComments.add(comment);
        comment = comment.next;
      }
      if (token == token.next) break;
      token = token.next;
    }

    // Process comments to find REFLECTION declarations and validate them
    for (int i = 0; i < allComments.length; i++) {
      var comment = allComments[i];
      var content = comment.lexeme.trim();

      if (_reflectionRegExp.hasMatch(content)) {
        _validateReflectionDeclaration(comment, allComments, i, reporter);
      }
    }
  }

  void _validateReflectionDeclaration(
      Token startComment, List<Token> allComments, int startIndex, reporter) {
    var content = startComment.lexeme.trim();

    // Check if the first line follows the proper format
    if (!_reflectionExpectedRegExp.hasMatch(content)) {
      reporter.atOffset(
        errorCode: _code,
        offset: startComment.offset,
        length: startComment.length,
      );
      return;
    }

    // Allow additional lines that are valid comment continuations
    // No need to validate continuation lines for format - they just need to be comments
    // The multi-line declaration is valid as long as the first line is proper
  }
}
