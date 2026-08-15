# Стабільна APK-збірка Shepit у Codemagic

## Що змінено

| Файл | Зміна |
|---|---|
| `android/build.gradle.kts` | Залишено стандартним, без `EOF`, `BaseExtension` і глобальних Android DSL-налаштувань. |
| `android/app/build.gradle.kts` | Додано Kotlin Android plugin; Java та Kotlin цілеспрямовано використовують JVM 17. |
| `test/widget_test.dart` | Шаблонний тест лічильника замінено на smoke test застосунку Shepit. |
| `codemagic.yaml` | Додано JDK 17, перевірку середовища, `flutter analyze`, `flutter test` і архівацію APK. |

## Як запустити

1. Розпакуйте цей архів і замініть відповідні файли у вашому репозиторії або завантажте проєкт як новий репозиторій.
2. Переконайтеся, що `codemagic.yaml` лежить у корені репозиторію та закомічений у гілку збірки.
3. У Codemagic виберіть workflow **`android-apk`** та натисніть **Start new build**.
4. Отримайте APK у вкладці **Artifacts** після успішного етапу `Build release APK`.

## Межі поточної конфігурації

APK збирається з debug signing, як і раніше. Він придатний для перевірки та внутрішнього поширення, але не підготовлений для Google Play. Для публікації потрібен окремий release keystore, який необхідно підключити через захищені налаштування Codemagic.

> Не додавайте `EOF` у жоден Gradle-файл. Це лише позначка для термінальних here-document команд, а не Kotlin або Gradle синтаксис.

## References

[1]: https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/ "Flutter apps — Codemagic Docs"

[2]: https://developer.android.com/build/jdks "Java versions in Android builds — Android Developers"
