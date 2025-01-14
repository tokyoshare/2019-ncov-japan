# TODO こちらのページの内容ではないから別のところに移動すべき、厚労省もまとめてくれないので、削除するのもあり
output$detail <- renderDataTable({
  datatable(detail,
            colnames = lang[[langCode]][37:48],
            rownames = NULL,
            caption = 'データの正確性を確保するため、厚生労働省の報道発表資料のみ参照するので、遅れがあります（土日更新しない模様）。',
            filter = 'top',
            escape = 11,
            selection = 'none',
            options = list(
              scrollCollapse = T,
              scrollX = T,
              autoWidth = T,
              columnDefs = list(
                list(width = '40px', targets = c(0, 1, 3, 4)),
                list(width = '60px', targets = c(2, 6, 7)),
                list(width = '80px', targets = c(8)),
                list(width = '100px', targets = c(5, 9, 10)),
                list(width = '630px', targets = 11)
              )
            )) %>%
    formatStyle(
      'observationStaus',
      target = 'row',
      background = styleEqual('終了', '#CCCCCC'),
    )
})

# ==== シンプルバージョンのテーブル表示==== (サイトが重い時に追加用)
observeEvent(input$switchTableVersion, {
  if (input$switchTableVersion) {
    output$summaryTable <- renderUI({
      dataTableOutput('summarybyRegionSub')
    })
  } else {
    output$summaryTable <- renderUI({
      dataTableOutput('summaryByRegion')
    })
  }
})

output$summarybyRegionSub <- renderDataTable({

    dt <- totalConfirmedByRegionData()[count > 0]
    # dt <- dt[count > 0]
    columnName <- c('today', 'death')
    dt[, (columnName) := replace(.SD, .SD == 0, NA), .SDcols = columnName]
    
    breaks <- seq(0, max(ifelse(is.na(dt$today), 0, dt$today), na.rm = T), 2)
    colors <- colorRampPalette(c(lightRed, darkRed))(length(breaks) + 1)
    
    breaksDeath <- seq(0, max(ifelse(is.na(dt$death), 0, dt$death), na.rm = T), 2)
    colorsDeath <- colorRampPalette(c('white', lightNavy))(length(breaksDeath) + 1)
    
    upMark <- as.character(icon('caret-up'))
    
    datatable(
      data = dt[, c(1, 3, 4, 9), with = F],
      colnames = c('都道府県', '新規', '感染者数', '死亡'),
      escape = F,
      plugins = 'natural', 
      extensions = c('Responsive'),
      options = list(
        paging = F,
        dom = 't',
        scrollY = '540px',
        scrollX = T,
        columnDefs = list(
          list(
            className = 'dt-center', 
            targets = c(1, 3:4)
          ),
          list(
            orderable = F,
            targets = 3:4
          )
        ),
        fnDrawCallback = htmlwidgets::JS('
      function() {
        HTMLWidgets.staticRender();
      }
    ')
      )
    ) %>% 
      spk_add_deps() %>%
      formatStyle(
        columns = 'totalToday',
        background = htmlwidgets::JS(
          paste0("'linear-gradient(-90deg, transparent ' + (", 
                 max(dt$count), "- value.split('<r ')[0])/", max(dt$count), 
                 " * 100 + '%, #DD4B39 ' + (", 
                 max(dt$count), "- value.split('<r ')[0])/", max(dt$count), 
                 " * 100 + '% ' + (", max(dt$count), "- value.split('<r ')[0] + Number(value.split('<r ')[1]))/", max(dt$count),
                 " * 100 + '%, #F56954 ' + (", 
                 max(dt$count), "- value.split('<r ')[0] + Number(value.split('<r ')[1]))/", max(dt$count), " * 100 + '%)'")
        ),
        backgroundSize = '100% 80%',
        backgroundRepeat = 'no-repeat',
        backgroundPosition = 'center') %>%
      formatCurrency(
        columns = 'today',
        currency = paste(as.character(icon('caret-up')), ' '),
        digits = 0) %>%
      formatStyle(
        columns = 'today', 
        color = styleInterval(breaks, colors),
        fontWeight = 'bold',
        backgroundSize = '80% 80%',
        backgroundPosition = 'center'
      ) %>%
      formatStyle(
        columns = 'death', 
        backgroundColor = styleInterval(breaksDeath, colorsDeath),
        fontWeight = 'bold',
        backgroundPosition = 'center'
      )
})

# TODO データ読み込み専用のところに移動
totalConfirmedByRegionData <- reactive({
  dt <- fread(paste0(DATA_PATH, 'resultSummaryTable.csv'), sep = '@')
  dt
})

output$summaryByRegion <- renderDataTable({
  # setcolorder(mergeDt, c('region', 'count', 'untilToday', 'today', 'diff', 'values'))
  # dt <- mergeDt[count > 0] # TEST
  dt <- totalConfirmedByRegionData()[count > 0]
  columnName <- c('today', 'death')
  dt[, (columnName) := replace(.SD, .SD == 0, NA), .SDcols = columnName]
  # TODO 感染拡大が終息する後からカラム復活、今は表示する必要はない
  # dt[, zeroContinuousDay := replace(.SD, .SD <= 0, NA), .SDcols = 'zeroContinuousDay']
  
  breaks <- seq(0, max(ifelse(is.na(dt$today), 0, dt$today), na.rm = T), 2)
  colors <- colorRampPalette(c(lightRed, darkRed))(length(breaks) + 1)
  
  breaksDeath <- seq(0, max(ifelse(is.na(dt$death), 0, dt$death), na.rm = T), 2)
  colorsDeath <- colorRampPalette(c('white', lightNavy))(length(breaksDeath) + 1)
  
  upMark <- as.character(icon('caret-up'))
  
  datatable(
    data = dt[, c(1, 3, 4, 6:9), with = F],
    colnames = c('都道府県', '新規', '感染者数', '新規感染', '新規退院', '内訳', '死亡'),
    escape = F,
    plugins = 'natural', 
    extensions = c('Responsive'),
    options = list(
      paging = F,
      dom = 't',
      scrollY = '540px',
      scrollX = T,
      columnDefs = list(
        list(
          className = 'dt-center', 
          width = '60px',
          targets = c(1, 3:5)
        ),
        list(
          className = 'dt-center', 
          width = '30px',
          targets = 6:7
        ),
        list(
          width = '30px',
          targets = 2
        ),
        list(
          orderable = F,
          targets = 3:6
        )
      ),
      fnDrawCallback = htmlwidgets::JS('
      function() {
        HTMLWidgets.staticRender();
      }
    ')
    )
  ) %>% 
    spk_add_deps() %>%
    formatStyle(
      columns = 'totalToday',
      background = htmlwidgets::JS(
        paste0("'linear-gradient(-90deg, transparent ' + (", 
          max(dt$count), "- value.split('<r ')[0])/", max(dt$count), 
          " * 100 + '%, #DD4B39 ' + (", 
          max(dt$count), "- value.split('<r ')[0])/", max(dt$count), 
          " * 100 + '% ' + (", max(dt$count), "- value.split('<r ')[0] + Number(value.split('<r ')[1]))/", max(dt$count),
          " * 100 + '%, #F56954 ' + (", 
          max(dt$count), "- value.split('<r ')[0] + Number(value.split('<r ')[1]))/", max(dt$count), " * 100 + '%)'")
      ),
      backgroundSize = '100% 80%',
      backgroundRepeat = 'no-repeat',
      backgroundPosition = 'center') %>%
    formatCurrency(
      columns = 'today',
      currency = paste(as.character(icon('caret-up')), ' '),
      digits = 0) %>%
    formatStyle(
      columns = 'today', 
      color = styleInterval(breaks, colors),
      fontWeight = 'bold',
      backgroundSize = '80% 80%',
      backgroundPosition = 'center'
    ) %>%
    formatStyle(
      columns = 'death', 
      backgroundColor = styleInterval(breaksDeath, colorsDeath),
      fontWeight = 'bold',
      backgroundPosition = 'center'
    ) #%>%
    # formatStyle(
    #   columns = 'zeroContinuousDay',
    #   background = styleColorBar(c(0, max(dt$zeroContinuousDay, na.rm = T)), lightBlue, angle = -90),
    #   backgroundSize = '98% 80%',
    #   backgroundRepeat = 'no-repeat',
    #   backgroundPosition = 'center')
})
