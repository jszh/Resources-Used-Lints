import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AiPromptFormatLint extends DartLintRule {
  static final _aiPromptRegExp =
      RegExp(r'//+\s*AI_PROMPT\b', caseSensitive: false);

  static final RegExp _aiPromptExpectedRegExp = RegExp(
    r'//\s*AI_PROMPT\((?=[^()]*\w)[^()\s](?:[^()]*[^()\s])?\):\s+.+',
  );

  const AiPromptFormatLint() : super(code: _code);

  static const _code = LintCode(
    name: 'ai_prompt_format',
    problemMessage:
        'AI_PROMPT comment must follow format: // AI_PROMPT(TOOL_NAME): Prompt text',
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

    // Process comments to find AI_PROMPT declarations and validate them
    for (int i = 0; i < allComments.length; i++) {
      var comment = allComments[i];
      var content = comment.lexeme.trim();

      if (_aiPromptRegExp.hasMatch(content)) {
        _validateAiPromptDeclaration(comment, allComments, i, reporter);
      }
    }
  }

  void _validateAiPromptDeclaration(
      Token startComment, List<Token> allComments, int startIndex, reporter) {
    var content = startComment.lexeme.trim();

    // Check if the first line follows the proper format
    if (!_aiPromptExpectedRegExp.hasMatch(content)) {
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
