## ============================================================
## 計量政治学 集中講義 共通設定
##
## 各 .qmd の冒頭チャンクで source("setup.R") と書いて読み込む。
## クラウド（JDCat分析ツール）でも、手元のPCでも動くようにしてある。
## ============================================================

## --- 必要なパッケージの確認 ---------------------------------
## 足りない場合は、何をインストールすればよいかを表示して止まる
.required <- c("tidyverse", "knitr", "modelsummary")
.missing  <- .required[!vapply(.required, requireNamespace,
                               logical(1), quietly = TRUE)]
if (length(.missing) > 0) {
  stop(
    "次のパッケージが入っていません:\n  ",
    paste(.missing, collapse = ", "),
    "\n\nConsole で次を実行してください:\n  install.packages(c(",
    paste0('"', .missing, '"', collapse = ", "), "))\n",
    call. = FALSE
  )
}

suppressPackageStartupMessages({
  library(tidyverse)
  library(knitr)
  library(modelsummary)
})

## --- 日本語フォントの自動選択 -------------------------------
## OSごとに候補を順に試し、実際に入っているものを使う。
## systemfonts が無い環境でも落ちないようにしてある。
.pick_jp_font <- function() {
  candidates <- switch(
    Sys.info()[["sysname"]],
    Windows = c("Yu Gothic", "Meiryo", "MS Gothic", "Noto Sans CJK JP"),
    Darwin  = c("Hiragino Sans", "Hiragino Kaku Gothic ProN",
                "YuGothic", "Noto Sans CJK JP"),
    ## Linux（クラウド環境）
    c("Noto Sans CJK JP", "IPAexGothic", "TakaoPGothic")
  )

  installed <- tryCatch(
    unique(systemfonts::system_fonts()$family),
    error = function(e) NULL      # systemfonts が無くても止めない
  )

  # フォント一覧を取得できない環境では、第1候補に賭ける
  if (is.null(installed)) return(candidates[1])

  # (a) 候補名と完全に一致するものを探す
  hit <- candidates[candidates %in% installed]
  if (length(hit) > 0) return(hit[1])

  # (b) 見つからない場合、日本語フォントらしい名前を広く探す
  #     （"Yu Gothic UI" のように名前が少し違う環境への保険）
  pattern <- "Gothic|Mincho|Meiryo|Hiragino|Noto Sans CJK|Noto Serif CJK"
  hit2 <- installed[grepl(pattern, installed, ignore.case = TRUE)]
  if (length(hit2) > 0) return(hit2[1])

  ""                                              # "" は既定フォント
}

JP_FIG <- .pick_jp_font()

if (!nzchar(JP_FIG)) {
  warning(
    "\u65e5\u672c\u8a9e\u30d5\u30a9\u30f3\u30c8\u304c\u898b\u3064\u304b\u308a\u307e\u305b\u3093\u3067\u3057\u305f\u3002",
    "\u30b0\u30e9\u30d5\u306e\u65e5\u672c\u8a9e\u304c\u56db\u89d2\u306b\u306a\u308b\u5834\u5408\u304c\u3042\u308a\u307e\u3059\u3002\n",
    "  jp_fonts() \u3067\u5229\u7528\u3067\u304d\u308b\u30d5\u30a9\u30f3\u30c8\u3092\u78ba\u8a8d\u3067\u304d\u307e\u3059\u3002",
    call. = FALSE
  )
}

## 使えるフォントの一覧を確認するための関数
##   jp_fonts()          … 日本語フォントらしいものを探す
##   jp_fonts(all = TRUE) … 全フォントを表示する
jp_fonts <- function(all = FALSE) {
  fams <- tryCatch(sort(unique(systemfonts::system_fonts()$family)),
                   error = function(e) NULL)
  if (is.null(fams)) {
    message("systemfonts \u30d1\u30c3\u30b1\u30fc\u30b8\u304c\u5fc5\u8981\u3067\u3059: install.packages(\"systemfonts\")")
    return(invisible(NULL))
  }
  if (all) return(fams)
  fams[grepl("Gothic|Mincho|Meiryo|Hiragino|CJK|Noto", fams, ignore.case = TRUE)]
}

## いま選ばれているフォントを表示する
message("\u56f3\u306e\u65e5\u672c\u8a9e\u30d5\u30a9\u30f3\u30c8: ",
        if (nzchar(JP_FIG)) JP_FIG else "(\u65e2\u5b9a)")

## --- ggplot2 の既定設定 -------------------------------------
theme_set(theme_bw(base_family = JP_FIG, base_size = 11))
update_geom_defaults("text",  list(family = JP_FIG))
update_geom_defaults("label", list(family = JP_FIG))

## --- 表の出力形式 -------------------------------------------
## Word 出力では Markdown 表を使う。罫線やフォントは
## reference-*.docx の「Table」スタイルが制御するので、R側の指定は不要。
## （flextable は Quarto の tbl-cap と衝突するため使わない）
options(modelsummary_factory_default = "markdown")

## --- その他 -------------------------------------------------
options(scipen = 999, digits = 3)


## ============================================================
## 記述統計表を作る補助関数
##
##   desc_table(df, age, educ, turnout,
##              labels = c(age = "年齢", educ = "教育年数"))
##
## ※ 内部では英数字の名前だけを使い、日本語は最後の見出しでのみ
##    使う。文字コードの違いによる不具合を避けるため。
## ============================================================
desc_table <- function(data, ..., labels = NULL, digits = 2) {
  out <- data |>
    dplyr::select(...) |>
    tidyr::pivot_longer(dplyr::everything(),
                        names_to = "var", values_to = "value") |>
    dplyr::group_by(var) |>
    dplyr::summarise(
      n    = sum(!is.na(value)),
      mean = mean(value, na.rm = TRUE),
      sd   = stats::sd(value, na.rm = TRUE),
      min  = min(value, na.rm = TRUE),
      med  = stats::median(value, na.rm = TRUE),
      max  = max(value, na.rm = TRUE),
      .groups = "drop"
    )

  ## 変数名を日本語ラベルに置き換える（指定があれば）
  if (!is.null(labels)) {
    idx <- match(out$var, names(labels))
    out$var[!is.na(idx)] <- unname(labels[idx[!is.na(idx)]])
  }

  ## 元の指定順に並べ替える
  ord <- names(dplyr::select(data, ...))
  if (!is.null(labels)) {
    ord_lab <- ifelse(ord %in% names(labels), labels[ord], ord)
  } else {
    ord_lab <- ord
  }
  out <- out[match(ord_lab, out$var), ]

  knitr::kable(
    out,
    digits    = digits,
    align     = "lrrrrrr",
    col.names = c("\u5909\u6570", "N", "\u5e73\u5747",
                  "\u6a19\u6e96\u504f\u5dee", "\u6700\u5c0f\u5024",
                  "\u4e2d\u592e\u5024", "\u6700\u5927\u5024")
  )
}
