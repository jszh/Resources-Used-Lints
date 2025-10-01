import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:custom_lint_builder/custom_lint_builder.dart';

const _desc =
    r'AI_PROMPT must be followed by AI_RESPONSE with the same tool name';

class AiPromptResponsePairLint extends DartLintRule {
  static final _aiPromptRegExp =
      RegExp(r'//\s*AI_PROMPT\(([^()\s]+)\):', caseSensitive: false);
  static final _aiResponseRegExp =
      RegExp(r'//\s*AI_RESPONSE\(([^()\s]+)\):', caseSensitive: false);
  static final _reflectionRegExp =
      RegExp(r'//\s*REFLECTION\b', caseSensitive: false);

  const AiPromptResponsePairLint() : super(code: _code);

  static const _code = LintCode(
      name: 'ai_prompt_response_pair',
      problemMessage: _desc,
      errorSeverity: DiagnosticSeverity.ERROR);

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

    Map<String, Token> promptTokens = {};

    // Process comments to find AI_PROMPT declarations
    for (int i = 0; i < allComments.length; i++) {
      var comment = allComments[i];
      var content = comment.lexeme.trim();

      var promptMatch = _aiPromptRegExp.firstMatch(content);
      if (promptMatch != null) {
        try {
          var toolName = promptMatch.group(1);
          if (toolName != null) {
            promptTokens[toolName] = comment;
          }
        } catch (e) {
          print('Error occurred while collecting prompts: $e');
        }
      }
    }

    // Check if each prompt has a matching response and proper ordering
    for (var entry in promptTokens.entries) {
      var toolName = entry.key;
      var promptToken = entry.value;

      var validationResult =
          _validatePromptResponsePair(allComments, toolName, promptToken);
      if (!validationResult.isValid) {
        reporter.atOffset(
          errorCode: _code,
          offset: promptToken.offset,
          length: promptToken.length,
        );
      }
    }
  }

  _ValidationResult _validatePromptResponsePair(
      List<Token> allComments, String toolName, Token promptToken) {
    // Find the position of the prompt token in the list
    int promptIndex = -1;
    for (int i = 0; i < allComments.length; i++) {
      if (allComments[i] == promptToken) {
        promptIndex = i;
        break;
      }
    }

    if (promptIndex == -1)
      return _ValidationResult(false, 'Prompt token not found');

    // Find the next REFLECTION after the prompt
    int? nextReflectionIndex;
    for (int i = promptIndex + 1; i < allComments.length; i++) {
      var comment = allComments[i];
      var content = comment.lexeme.trim();
      var reflectionMatch = _reflectionRegExp.firstMatch(content);
      if (reflectionMatch != null) {
        nextReflectionIndex = i;
        break;
      }
    }

    // Look for AI_RESPONSE with the same tool name in subsequent comments
    // but before the next REFLECTION (if any)
    int searchLimit = nextReflectionIndex ?? allComments.length;

    for (int i = promptIndex + 1; i < searchLimit; i++) {
      var comment = allComments[i];
      var content = comment.lexeme.trim();
      var match = _aiResponseRegExp.firstMatch(content);
      try {
        if (match != null && match.group(1) == toolName) {
          return _ValidationResult(true, 'Valid prompt-response pair');
        }
      } catch (e) {
        print('Error occurred while checking responses: $e');
      }
    }

    if (nextReflectionIndex != null) {
      return _ValidationResult(
          false, 'AI_RESPONSE not found before the next REFLECTION');
    } else {
      return _ValidationResult(false, 'AI_RESPONSE not found');
    }
  }
}

class _ValidationResult {
  final bool isValid;
  final String message;

  _ValidationResult(this.isValid, this.message);
}
