#
# Script para baixar os dados de membros de órgãos da Câmara dos Deputados
# Fonte: API de Dados Abertos da Câmara dos Deputados
# Abrangência: 51a-56a legislaturas (todos os dados disponíveis nos Dados Abertos)
# Saída: documento CSV (pode lido diretamente no OpenOffice-Calc ou MS-Excel)
#

# Carrega pacotes
library(httr)
library(jsonlite)

txtURLbase = "https://dadosabertos.camara.leg.br/api/v2/orgaos/"

carrega_membros <- function(txtURLbase, idOrgaos) {
  
  dataMembros <- data.frame()
  for (idOrgao in idOrgaos) {
    
    numPagina <- 1  
    txtURL = paste(txtURLbase, idOrgao, 
                   "/membros?dataInicio=1999-01-01&dataFim=2022-07-09&itens=100", 
                   sep="")
    print(txtURL)
    repeat {
      
      # Tenta acessar a página e carregar os dados (sai do laço caso ela não exista)
      txtURL_p = paste(txtURL, "&pagina=", as.character(numPagina), sep="")
      get_membros <- GET(url = txtURL_p)
      status <- status_code(get_membros)
      if (status != 200) {
        break
      }
      
      # Converte conteúdo em texto, com codificação UTF-8
      get_membros_texto <- content(get_membros,
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
  }
  
  return(dataMembros)
}

# "wrappers" para a função principal

## Mesa da Câmara dos Deputados
carrega_membros_mesa <- function(txtURLbase) {
  idMesa <- c(4)
  return(carrega_membros(txtURLbase, idMesa))
}

## Presidência da Câmara dos Deputados (PCD)
carrega_membros_pcd <- function(txtURLbase) {
  return(carrega_membros(txtURLbase, idOrgao=249))
}

## Comissões Permanentes (CP)
## (*em validação*)
carrega_membros_cp <- function(txtURLbase) {
  idComissoesPermanentes <- 2001L:2018L
  return(carrega_membros(txtURLbase, idComissoesPermanentes))
}

# Testando as funções:
# Executa carga e grava os dados em formato CSV
# Descomente as linhas referentes aos tipos de órgãos desejados

## Mesa da Câmara dos Deputados
#dataMembros <- carrega_membros_mesa(txtURLbase)
#write.csv(dataMembros, "membros_mesa_51a_56a.csv")

## Comissões Permanentes da Câmara dos Deputados
dataMembros <- carrega_membros_cp(txtURLbase)
write.csv(dataMembros, "membros_cp_51a_56a.csv")
