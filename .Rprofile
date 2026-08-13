## =============================================================
## R セッションから quarto コマンドを見つけられるようにする
## （RStudio の Render ボタンはこの PATH を参照する）
## =============================================================
local({
  cand <- c(
    file.path(Sys.getenv("NB_PYTHON_PREFIX", "/srv/conda/envs/notebook"), "bin"),
    "/srv/conda/envs/notebook/bin",
    file.path(Sys.getenv("HOME"), ".local", "bin")
  )
  cur <- strsplit(Sys.getenv("PATH"), ":", fixed = TRUE)[[1]]
  add <- unique(cand[dir.exists(cand) & !(cand %in% cur)])
  if (length(add)) Sys.setenv(PATH = paste(c(add, cur), collapse = ":"))
})
