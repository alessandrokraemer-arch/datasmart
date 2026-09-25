USE [master]
GO

CREATE DATABASE [DDS]
GO

USE [DDS]
GO

SET QUOTED_IDENTIFIER ON
GO

/****** AQUI UMA TABELA RUIM POIS SOZINHO COM CNPJ RESOLVE... ******/
/****** Object:  Table [DDS].[dbo].[Fato_Saldo_da_Loja]  ******/
CREATE TABLE [DDS].[dbo].[Fato_Saldo_da_Loja](
	[idPK] [int] IDENTITY(1,1) NOT NULL,
	[idHistFK] [int] NOT NULL,
	[empresa] [varchar](50) NULL,
	[saldo] [float] NULL,
	[insertTimestamp] [datetime] NULL,
	[updateTimestamp] [datetime] NULL)
GO

ALTER TABLE [DDS].[dbo].[Fato_Saldo_da_Loja]  WITH CHECK ADD  CONSTRAINT [FK_Fato_Saldo_da_Loja_Historia_Caixa_da_Loja] FOREIGN KEY([idHistFK])
REFERENCES [DDS].[dbo].[Historia_Caixa_da_Loja] ([idPK])

/****** Object:  Table [DDS].[dbo].[Historia_Caixa_da_Loja]  ******/
CREATE TABLE [DDS].[dbo].[Historia_Caixa_da_Loja](
	[idPK] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[cnpjFK] [varchar](14) NOT NULL,
	[notaPK] varchar(50) NULL,
	[receita] [float] NULL,
	[despesa] [float] NULL,
	[mes] [int] NULL,
	[ano] [int] NULL,
	[insertTimestamp] [datetime] NOT NULL
)
GO


/****** Object:  Procedure [DDS].[dbo].[atualizaFato_Saldo_da_Loja]  ******/
/****** ISSO AQUI ABAIXO COMPREENDE O SCD... ******/
CREATE PROCEDURE atualizaFato_Saldo_da_Loja AS
BEGIN
	/****** AQUI NESTE BLOCO O QUANDO HÁ NOVA TUPLA INSERIDA EM RH QUE AINDA NÃO ESTEJA NO FATO ALI ******/
	INSERT INTO [DDS].dbo.Fato_Saldo_da_Loja (cnpjPK,empresa,saldo,insertTimestamp,updateTimestamp)
	SELECT  [NDS].dbo.RH.cnpjPK, 
			[NDS].dbo.RH.nomeFantasia,
			[NDS].dbo.Caixa.saldo,
			getDate(),
			getDate()
	FROM [NDS].dbo.RH INNER JOIN [NDS].dbo.Caixa ON [NDS].dbo.RH.cnpjPK = [NDS].dbo.Caixa.cnpjFK
	WHERE NOT EXISTS (
		SELECT * FROM [DDS].dbo.Fato_Saldo_da_Loja WHERE cnpjPK = [NDS].dbo.RH.cnpjPK
	)

	/****** AQUI NESTE NOVO BLOCO O QUANDO O SCD IDENTIFICA UMA ALTERAÇÃO E 
	NÃO NECESSITO INSERIR A TUPLA INTEIRA NOVAMENTE ******/
	UPDATE [DDS].dbo.Fato_Saldo_da_Loja SET [DDS].dbo.Fato_Saldo_da_Loja.saldo = [NDS].dbo.Caixa.saldo,
	[DDS].dbo.Fato_Saldo_da_Loja.updateTimestamp = getDate() FROM [DDS].dbo.Fato_Saldo_da_Loja
	INNER JOIN [NDS].dbo.Caixa ON [NDS].dbo.Caixa.cnpjFK = [DDS].dbo.Fato_Saldo_da_Loja.cnpjPK
	WHERE [DDS].dbo.Fato_Saldo_da_Loja.cnpjPK = [NDS].dbo.Caixa.cnpjFK AND
	[NDS].dbo.Caixa.dataReceita > [DDS].dbo.Fato_Saldo_da_Loja.updateTimestamp 

	/****** AQUI NESTE BLOCO O QUANDO HÁ NOVA TUPLA INSERIDA EM HISTÓRIA QUE AINDA NÃO ESTEJA NA DIM ALI ******/
	INSERT INTO [DDS].dbo.[Historia_Caixa_da_Loja] (cnpjFK,notaPK,receita,despesa,mes,ano,insertTimestamp)
	SELECT [NDS].dbo.Historia.cnpjFK, 
		   [NDS].dbo.Historia.externoPK AS notaPK, 
		   (CASE
				WHEN [NDS].dbo.Historia.operacao = 'RECEITA' THEN [NDS].dbo.Historia.valor
		   END),
		   (CASE
				WHEN [NDS].dbo.Historia.operacao = 'DESPESA' THEN [NDS].dbo.Historia.valor
		   END),
		   MONTH([NDS].dbo.Historia.dataMovimento),
		   YEAR([NDS].dbo.Historia.dataMovimento),
		   getDate()
	FROM [NDS].dbo.Historia
	WHERE NOT EXISTS (
		SELECT * FROM [DDS].dbo.[Historia_Caixa_da_Loja] WHERE notaPK = [NDS].dbo.Historia.externoPK
	)

	/****** HÁ COMO AVERIGUAR A CONFIANÇA DO SALDO ******/
	/****** ... ******/
END
GO

/****** AQUI VOCÊ DEVA EXECUTAR A PROCEDURE QUANDO QUER ATUALIZAR O FATO ******/
/****** OBSERVE O SCD (SLOWLY CHANGING DIMENSION) ... ******/
EXEC atualizaFato_Saldo_da_Loja
GO

