## ============================================================
## 計量政治学 集中講義 共通設定
## 各 .qmd の冒頭チャンクで source("setup.R") と書いて読み込む
## ============================================================

library(tidyverse)
library(knitr)
library(modelsummary)

## --- 図の日本語フォント -------------------------------------
## レンダリングは常にクラウド上の Linux で行われるため、
## 学生の PC が Windows でも Mac でも図のフォントは共通。
## 日本語フォントは apt.txt により自動導入される。
JP_FIG <- "Noto Sans CJK JP"

if (!any(grepl("Noto Sans CJK", systemfonts::system_fonts()$family))) {
  warning("日本語フォントが見つかりません。apt.txt の設定を確認してください。")
}

theme_set(theme_bw(base_family = JP_FIG, base_size = 11))
update_geom_defaults("text",  list(family = JP_FIG))
update_geom_defaults("label", list(family = JP_FIG))

## --- 表の出力形式 -------------------------------------------
## Word 出力では Markdown 表を使う。罫線・フォント・文字サイズは
## reference-*.docx の「Table」スタイルが制御するので、
## R 側で書式指定は不要。
##
## ※ flextable は Quarto の tbl-cap と衝突して
##   Word が「破損」と判定するファイルを生成するため使わない。
options(modelsummary_factory_default = "markdown")

## --- その他 -------------------------------------------------
options(scipen = 999, digits = 3)

## 記述統計表を作る補助関数（授業用）
## 例: desc_table(df, age, educ, turnout)
desc_table <- function(data, ...,
                       labels = NULL, digits = 2) {
  out <- data |>
    dplyr::select(...) |>
    tidyr::pivot_longer(dplyr::everything(),
                        names_to = "変数", values_to = ".v") |>
    dplyr::summarise(
      .by = "変数",
      N        = sum(!is.na(.v)),
       平均     = mean(.v, na.rm = TRUE),
      標準偏差 = sd(.v, na.rm = TRUE),
      最小値   = min(.v, na.rm = TRUE),
      最大値   = max(.v, na.rm = TRUE)
    )
  if (!is.null(labels)) out$変数 <- dplyr::recode(out$変数, !!!labels)
  knitr::kable(out, digits = digits, align = "lrrrrr")
}
