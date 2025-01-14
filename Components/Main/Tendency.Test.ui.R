tabPanel(
  # PCR検査数推移
  title = 'PCR検査数の推移',
  icon = icon('vials'),
  value = 'pcr',
  fluidRow(
    column(
      width = 8,
      tags$br(),
      fluidRow(
        column(
          width = 6,
          switchInput(
            inputId = "showShipInPCR",
            label = icon('ship'), 
            offLabel = icon('eye-slash'), 
            onLabel = icon('eye'),
            value = F,
            inline = T
          ),
          switchInput(
            inputId = "showFlightInPCR",
            label = icon('plane'),
            offLabel = icon('eye-slash'), 
            onLabel = icon('eye'),
            value = T,
            inline = T
          )
        )
      ),
      echarts4rOutput('pcrLine') %>% withSpinner()
    ),
    column(
      width = 4,
      tagList(
        tags$br(),
        tags$b('注意点'),
        tags$li(lang[[langCode]][98]), # 「令和２年３月４日版」以後は、陽性となった者の~
        tags$li(lang[[langCode]][99]), # これまで延べ人数で公表しましたクルーズ船のＰＣＲ~
        tags$br(),
        tags$a(
          href = 'https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/0000121431_00086.html',
          icon('link'),
          '報道発表一覧（新型コロナウイルス）'
        ),
        tags$hr(),
        tags$b('PCR検査数（日次）')
      ),
      echarts4rOutput('pcrCalendar', height = '130px') %>% withSpinner()
    )
  )
)
