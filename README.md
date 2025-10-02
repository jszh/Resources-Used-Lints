# Resources Used Lints

Lint rules for documentation of resources used in CSE 340.

## Overview

This package provides lint rules to ensure students properly document their use of external resources and AI tools in their code comments, following a format similar to Flutter's TODO comment style.

## Comment Formats

### CONSULTED Comments

Document external resources consulted:

```dart
// CONSULTED(URL_OF_RESOURCE): Explanation of how the resource was used
```

Example:

```dart
// CONSULTED(https://stackoverflow.com/questions/12345): Found algorithm for sorting implementation
```

### AI_PROMPT Comments

This must be followed by an AI_RESPONSE comment.
Document prompts given to AI tools:

```dart
// AI_PROMPT(GENAI_TOOL_NAME): The prompt text provided to the AI
```

### AI_RESPONSE Comments

Document responses received from AI tools:

```dart
// AI_RESPONSE(GENAI_TOOL_NAME): The output received from the AI
//   Additional lines of response can continue
//   with proper indentation
```

### AI_OTHER Comments

Document other uses of AI tools:

```dart
// AI_OTHER(GENAI_TOOL_NAME): Description of other AI assistance received
```

### REFLECTION Comments

This must follow CONSULTED or AI_* comments.
Document learning and modifications made:

```dart
// REFLECTION: Student reflection on what was learned and any changes made
```

## Lint Rules

### Format Rules

- `consulted_format`: Ensures CONSULTED comments follow the proper format
- `ai_prompt_format`: Ensures AI_PROMPT comments follow the proper format
- `ai_response_format`: Ensures AI_RESPONSE comments follow the proper format
- `ai_other_format`: Ensures AI_OTHER comments follow the proper format
- `reflection_format`: Ensures REFLECTION comments follow the proper format

### Relationship Rules

- `ai_prompt_response_pair`: Ensures every AI_PROMPT is followed by an AI_RESPONSE with the same tool name
- `reflection_required`: Ensures all CONSULTED and AI\_\* comments are followed by REFLECTION comments

## Usage

1. Add this package as a dev dependency in your `pubspec.yaml`:

```yaml
dev_dependencies:
  resources_used_lints:
  custom_lint: ^0.7.3
```

2. Create or update your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    # Resource documentation format rules
    - consulted_format
    - ai_prompt_format
    - ai_response_format
    - ai_other_format
    - reflection_format

    # Relationship validation rules
    - ai_prompt_response_pair
    - reflection_required
```

3. Run the linter:

```bash
dart run custom_lint
```

## Example Valid Comment Sequence

```dart
// CONSULTED(https://dart.dev/guides/language/language-tour): Learned about async/await
// REFLECTION: Understanding async programming helped me write better concurrent code

// AI_PROMPT(ChatGPT): How do I implement error handling in async functions?
// AI_RESPONSE(ChatGPT): Use try-catch blocks around await expressions and handle specific exception types
// REFLECTION: I had to add additional null checks that the AI didn't mention

// AI_OTHER(GitHub Copilot): Used for auto-completing import statements
// REFLECTION: Copilot suggestions saved time but I verified each import was actually needed
```
