## ============================================================
## QoG Standard Dataset（時系列版）の取得
##
## 【演習5で使う。学生が1回だけ実行するスクリプト】
##
## 演習1で使った Basic 版には紛争変数が入っていないため、
## より収録変数の多い Standard 版を使う。
## 必要な列だけを抜き出して保存するので、2回目以降は実行不要。
## ============================================================

## --- 設定 ---------------------------------------------------
## 版が更新されたら、ここを書き換える
## 最新版は https://www.gu.se/en/quality-government/qog-data
QOG_VERSION <- "jan26"
QOG_URL <- paste0("https://www.qogdata.pol.gu.se/data/qog_std_ts_",
                  QOG_VERSION, ".csv")

OUT_FILE <- "data/qog_conflict.csv"
dir.create("data", showWarnings = FALSE)

## 既定の60秒では間に合わないので、必ず延長しておく
options(timeout = 1800)

if (file.exists(OUT_FILE)) {
  message("すでに ", OUT_FILE, " があります。処理を終了します。")
} else {

  message("QoG Standard データを読み込んでいます（数分かかります）…")

  ## col_select で必要な列だけを読む。これで使用メモリを大きく減らせる
  qog <- readr::read_csv(
    QOG_URL,
    col_select = c(
      cname, ccodealp, year, ht_region,          # 国と地域
      ucdp_type2, ucdp_type3, ucdp_type4,        # 紛争
      vdem_polyarchy, p_polity2,                 # 民主主義
      wdi_gdpcapcon2015, wdi_pop, wdi_popurb,    # 経済・人口
      ross_oil_value_2014, ef_ef                 # 石油・民族分断
    ),
    show_col_types = FALSE
  )

  readr::write_csv(qog, OUT_FILE)
  message(OUT_FILE, " を作成しました（", nrow(qog), " 行）")
}

## --- 確認 ---------------------------------------------------
qog <- readr::read_csv(OUT_FILE, show_col_types = FALSE)
cat("行数    :", nrow(qog), "\n")
cat("年の範囲:", min(qog$year), "-", max(qog$year), "\n")
cat("列      :", paste(names(qog), collapse = ", "), "\n")

## ============================================================
## 出典（レポートに必ず記載すること）
##   Teorell, Jan, et al. The Quality of Government Standard Dataset,
##   version Jan26. University of Gothenburg:
##   The Quality of Government Institute.
##
##   紛争変数の原典は UCDP/PRIO Armed Conflict Dataset。
##   QoG のデータは再配布が認められていない。各自で取得すること。
## ============================================================
