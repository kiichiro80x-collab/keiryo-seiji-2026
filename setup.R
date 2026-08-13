## ============================================================
## 計量政治学 集中講義 共通設定
## 各 .qmd の冒頭チャンクで source("setup.R") と書いて読み込む
## ============================================================

library(tidyverse)
library(flextable)

## --- 図の日本語フォント -------------------------------------
## レンダリングは Posit Cloud (Linux) 上で行われるため、
## 学生の PC が Windows でも Mac でも、図のフォントは常にこれ。
## 事前に Terminal で次を1回だけ実行しておくこと:
##   sudo apt-get update && sudo apt-get install -y fonts-noto-cjk
JP_FIG <- "Noto Sans CJK JP"

if (!any(grepl("Noto Sans CJK", systemfonts::system_fonts()$family))) {
  warning(
    "日本語フォントが見つかりません。Terminal で次を実行してください:\n",
    "  sudo apt-get update && sudo apt-get install -y fonts-noto-cjk"
  )
}

theme_set(theme_bw(base_family = JP_FIG, base_size = 11))
update_geom_defaults("text",  list(family = JP_FIG))
update_geom_defaults("label", list(family = JP_FIG))

## --- 表の既定書式（Word のネイティブ表として出力）-----------
## font.family は Word 側で使うフォント名。
## Mac の学生は "Hiragino Mincho ProN" に変更してもよい。
set_flextable_defaults(
  font.family  = "游明朝",
  font.size    = 9,
  padding      = 3,
  border.color = "gray40",
  table.layout = "autofit",
  digits       = 3
)

## modelsummary の既定出力を flextable に
options(modelsummary_factory_default = "flextable")

## --- その他 -------------------------------------------------
options(scipen = 999, digits = 3)
