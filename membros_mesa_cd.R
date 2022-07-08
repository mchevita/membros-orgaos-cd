#
# Script para baixar os dados de membros da Mesa-Diretora da Câmara dos Deputados
# Fonte: API de Dados Abertos da Câmara dos Deputados
# Abrangência: 51a-56a legislaturas (todos os dados disponíveis nos Dados Abertos)
# Saída: documento XLSX (Excel)
#

# Carrega pacotes
library(httr)
library(jsonlite)
library(xlsx)

txtURLbase = "https://dadosabertos.camara.leg.br/api/v2/orgaos/4/membros?dataInicio=1999-01-01&dataFim=2022-07-05&itens=100"

carrega_membros_mesa <- function(txtURLbase) {

  numPagina <- 1  
  dataMembros <- data.frame()

  repeat {
    # Obtém detalhes da API
    txtURL = paste(txtURLbase, "&pagina=", as.character(numPagina), sep="")
    get_membros <- GET(url = txtURL)
    
    # Obtém o status da chamada HTTP e sai do laço caso ela não exista
    status <- status_code(get_membros)
    if (status != 200) {
      break
    }
    
    # Converte conteúdo em texto, com codificação UTF-8
    get_membros_texto <- content(
      get_membros,
      "text", 
      encoding = "UTF-8")
    
    # Converte os dados para JSON; sai do laço caso a página não retorne dados
    get_membros_json <- fromJSON(get_membros_texto,
                                 flatten = TRUE)
    if (length(get_membros_json$dados) == 0) {
      break
    }
    
    # Converte os dados para dataframe
    get_membros_dataframe <- as.data.frame(get_membros_json$dados)
    
    # Concatena os dataframes
    dataMembros <- rbind(dataMembros, get_membros_dataframe)
    
    # Incrementa o contador de páginas
    numPagina <- numPagina + 1
  }
  
  return(dataMembros)
}

# Executa carga e grava os dados em formato XLS (Excel)
dataMembros <- carrega_membros_mesa(txtURLbase)
write.xlsx(dataMembros, "membros_mesa_51a_56a.xlsx")
