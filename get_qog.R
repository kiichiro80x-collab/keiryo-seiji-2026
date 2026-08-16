## ============================================================
## QoG Basic Dataset（時系列版）の取得
##
## 【学生が最初に1回だけ実行するスクリプト】
##
## QoGのデータは再配布が認められていないため、
## 各自が公式サイトから直接ダウンロードする。
## 一度取得すれば環境に保存されるので、2回目以降は実行不要。
## ============================================================

## --- 設定 ---------------------------------------------------
## 版が更新されたら、ここを書き換える
## 最新版は https://www.gu.se/en/quality-government/qog-data/data-downloads/basic-dataset
QOG_VERSION <- "jan26"
QOG_URL <- paste0("https://www.qogdata.pol.gu.se/data/qog_std_ts_jan26.csv",
                  QOG_VERSION, ".csv")

RAW_FILE <- file.path("data", paste0("qog_bas_ts_", QOG_VERSION, ".csv"))
OUT_FILE <- "data/qog_polyarchy.csv"

dir.create("data", showWarnings = FALSE)

## --- ダウンロード -------------------------------------------
## 既定の60秒では間に合わないので、必ず延長しておく
options(timeout = 900)

if (file.exists(OUT_FILE)) {
  message("すでに ", OUT_FILE, " があります。処理を終了します。")
} else {

  if (!file.exists(RAW_FILE)) {
    message("QoGデータをダウンロードしています（約15MB／数分かかります）…")
    ok <- tryCatch({
      download.file(QOG_URL, RAW_FILE, mode = "wb")
      TRUE
    }, error = function(e) {
      message("ダウンロードに失敗しました: ", conditionMessage(e))
      FALSE
    })

    ## 途中で切れた不完全なファイルは削除する
    if (!ok || file.size(RAW_FILE) < 5 * 1024^2) {
      unlink(RAW_FILE)
      stop("ダウンロードが完了しませんでした。時間をおいて再実行してください。")
    }
  }

  message("読み込んでいます…")
  qog <- readr::read_csv(
    RAW_FILE,
    col_select = c(cname, ccodealp, year, vdem_polyarchy, ht_region),
    show_col_types = FALSE
  )

  readr::write_csv(qog, OUT_FILE)
  message(OUT_FILE, " を作成しました（", nrow(qog), " 行）")

  ## 元の大きいファイルは削除して容量を節約する
  unlink(RAW_FILE)
}

## --- 確認 ---------------------------------------------------
qog <- readr::read_csv(OUT_FILE, show_col_types = FALSE)
cat("行数              :", nrow(qog), "\n")
cat("年の範囲          :", min(qog$year), "-", max(qog$year), "\n")
cat("polyarchy の最終年:", max(qog$year[!is.na(qog$vdem_polyarchy)]), "\n")

## ============================================================
## 出典（レポートに必ず記載すること）
##   Dahlberg, Stefan, Aksel Sundström, Sören Holmberg, Bo Rothstein,
##   Natalia Alvarado Pachon, Victor Saidi Phiri & Zhen Liu. 2026.
##   The Quality of Government Basic Dataset, version Jan26.
##   University of Gothenburg: The Quality of Government Institute.
##   https://doi.org/10.18157/qogbasjan26
##
##   polyarchy 指標の原典は V-Dem プロジェクト。原典も併記すること。
## ============================================================
