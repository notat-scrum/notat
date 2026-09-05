# Como contribuir

## Idioma

Código, nomes de arquivo, rotas e textos de interface em inglês. Issues, commits, comentários no
código e documentação em pt-BR.

Mensagens de commit vão sem acento, para não depender da configuração de encoding de quem lê o
histórico no terminal. Nos demais textos, escreva com acento normalmente.

## Quadro

O [quadro do projeto](https://github.com/orgs/notat-scrum/projects/1) tem três colunas:

| Coluna | Quando |
|---|---|
| Backlog | a issue existe e ninguém pegou |
| Em desenvolvimento | alguém começou, mesmo que ainda não tenha commitado |
| Pronto | o PR que fecha a issue foi mergeado |

Mova o card quando o estado muda, não no fim do trabalho. Quem olha o quadro precisa saber o que está
acontecendo agora.

Issue nova não entra sozinha no quadro. Depois de criar:

```
gh project item-add 1 --owner notat-scrum --url <url-da-issue>
```

## Issues

Uma issue descreve um resultado, não uma tarefa. Duas seções:

```markdown
**Feito quando:** o critério que qualquer pessoa consegue conferir sem perguntar nada.

**Toca:** os arquivos ou pastas que devem mudar.
```

Se o critério não dá para conferir, ele não está pronto para virar issue.

## Branches

Uma branch por frente de trabalho, criada a partir da `master`:

```
git checkout master
git pull
git checkout -b docs/documentacao-e-cobertura
```

O nome tem o formato `tipo/descricao-em-kebab-case`, com os mesmos tipos dos commits. A descrição
precisa fazer sentido sozinha para quem não acompanhou a conversa, então nada de `feat/etapa-2`.

## Commits

[Conventional Commits](https://www.conventionalcommits.org/pt-br/), com o número da issue no fim:

```
fix: aplica a regra de senha forte so no cadastro (#31)
refactor: remodela as colecoes do Firestore para users/{uid} (#25)
docs: reescreve o README com o setup do projeto (#37)
```

Tipos em uso: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`, `infra`.

**Uma issue, um commit.** Se a issue precisa de dois commits, ou ela era duas issues, ou o segundo
commit é conserto do primeiro e cabe um `git commit --amend` antes do push.

Só use corpo no commit quando a mudança é ampla e o cabeçalho não dá conta. Aí o corpo vira bullets
explicando o porquê, não a lista do que mudou, que o diff já mostra.

## Pull requests

Abra o PR contra a `master`. O corpo segue esta estrutura:

```markdown
## Por que
O que estava errado ou faltando, em dois parágrafos no máximo.

## Verificação
A saída real dos comandos, colada. Não escreva que passou; mostre.

## O que mudou
Uma subseção `###` por assunto.

---

Closes #1, closes #2
```

Repita a palavra `closes` em cada número. O GitHub só fecha as issues assim.

Antes de pedir review, rode o que o CI roda:

```
fvm dart format .
fvm flutter analyze --fatal-infos
fvm dart analyze
fvm flutter test
```

Os dois `analyze` são necessários: o `riverpod_lint` entra pelo `analysis_server_plugin`, que o
`flutter analyze` não carrega. O CI também comenta a cobertura de testes no PR, como número
acompanhado, não meta a bater.

**Merge commit, nunca squash.** O histórico por issue é o registro de quando cada decisão entrou, e o
squash apaga isso.

## Rodar o projeto

O setup, do zero, está no [README](README.md).
