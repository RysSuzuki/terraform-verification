# 実行環境インストール

tf インストール

```
$ brew install tfenv
$ tfenv install 1.0.x
$ terraform --version
```

# 環境切り替え

現在の確認

```
$ terraform workspace show
```

環境作成

```
$ terraform workspace new dev
```

環境一覧確認

```
$ terraform workspace list
```

環境切り替え

```
$ terraform workspace select dev
```
