<!-- Título: frase no presente dizendo o que o PR entrega, sem número de issue.
Ex.: "Prova a sincronização offline e avisa quando a gravação falha". -->

## Por que

<!-- Qual issue e qual critério de aceite este PR atende, e o que estava errado ou faltando.
Dois parágrafos no máximo. -->

## Verificação

<!-- A saída real dos comandos, colada. Não escreva que passou; mostre. -->

```
$ fvm flutter analyze --fatal-infos

$ fvm dart analyze

$ fvm flutter test

```

### Teste antes da mudança

<!-- Correção de bug: o teste que falhou antes e passou depois.
Refatoração: o teste de regressão que passou antes e depois, sem alteração.
Diga em qual commit está cada estado e cole o print do vermelho e do verde. -->

### Validação no aparelho

<!-- Os passos feitos no emulador e o print de cada um.
Se o PR não muda nada visível no app, diga por quê e apague o resto desta seção. -->

## O que mudou

<!-- Uma subseção ### por assunto. -->

## Checklist da Definition of Done

- [ ] Teste escrito antes da mudança, com o vermelho e o verde (ou a regressão antes e depois) acima
- [ ] O que os arquivos tocados fazem e ainda não tinha teste ganhou teste
- [ ] Linha no catálogo de code smells do README, se o PR corrige um smell
- [ ] Prints da validação no aparelho, se o PR muda algo visível
- [ ] CI verde

---

<!-- Repita "closes" em cada número; o GitHub só fecha as issues assim.
Se o PR entrega só parte da issue, escreva "Parte da #N" em vez de "Closes". -->

Closes #
