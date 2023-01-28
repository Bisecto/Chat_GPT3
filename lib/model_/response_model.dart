// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  Welcome({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  String id;
  String object;
  int created;
  String model;
  List<Choice> choices;
  Usage usage;

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
    id: json["id"],
    object: json["object"],
    created: json["created"],
    model: json["model"],
    choices: List<Choice>.from(json["choices"].map((x) => Choice.fromJson(x))),
    usage: Usage.fromJson(json["usage"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "object": object,
    "created": created,
    "model": model,
    "choices": List<dynamic>.from(choices.map((x) => x.toJson())),
    "usage": usage.toJson(),
  };
}

class Choice {
  Choice({
    required this.text,
    required this.index,
    this.logprobs,
    required this.finishReason,
  });

  String text;
  int index;
  dynamic logprobs;
  String finishReason;

  factory Choice.fromJson(Map<String, dynamic> json) => Choice(
    text: json["text"],
    index: json["index"],
    logprobs: json["logprobs"],
    finishReason: json["finish_reason"],
  );

  Map<String, dynamic> toJson() => {
    "text": text,
    "index": index,
    "logprobs": logprobs,
    "finish_reason": finishReason,
  };
}

class Usage {
  Usage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  int promptTokens;
  int completionTokens;
  int totalTokens;

  factory Usage.fromJson(Map<String, dynamic> json) => Usage(
    promptTokens: json["prompt_tokens"],
    completionTokens: json["completion_tokens"],
    totalTokens: json["total_tokens"],
  );

  Map<String, dynamic> toJson() => {
    "prompt_tokens": promptTokens,
    "completion_tokens": completionTokens,
    "total_tokens": totalTokens,
  };
}
