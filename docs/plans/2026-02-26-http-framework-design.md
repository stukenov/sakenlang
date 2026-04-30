# sakenlang HTTP Framework — Design

## Синтаксис

```swift
route("GET", "/", func() {
    return "Привет, мир!"
})

route("POST", "/api/echo", func() {
    let name = param("name")
    return "Салем, " + name + "!"
})

serve(3000)
```

## Встроенные функции

- `route(method, path, handler)` — регистрирует обработчик
- `serve(port)` — запускает HTTP-сервер
- `param(name)` — query/body параметр текущего запроса
- `header(name)` — HTTP заголовок запроса
- `status(code)` — установить код ответа (200 по умолчанию)

## Архитектура

Evaluator хранит таблицу маршрутов (hash: "METHOD /path" → handler func).
`serve(port)` запускает Racket `web-server/http` сервер.
При запросе — поиск маршрута, вызов handler, строка-ответ как text/html.

## Ограничения v1

- Ответ — строка (HTML/текст)
- Нет middleware, файлов, JSON
