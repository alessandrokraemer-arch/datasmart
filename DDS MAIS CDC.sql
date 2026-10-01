USE [master]
GO

CREATE DATABASE DDS
GO

USE [DDS]
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Object:  Table [dbo].[Calendario]  ******/
CREATE TABLE [dbo].[Calendario](
	[idPK] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[mes] [int] NOT NULL,
	[ano] [int] NOT NULL,
	[insertTimestamp] [datetime] NOT NULL)
GO

/****** Object:  Table [dbo].[Fato_Saldo_da_Loja]  ******/
CREATE TABLE [dbo].[Fato_Saldo_da_Loja](
	[cnpjFK] [varchar](14) NULL,
	[empresa] [varchar](50) NULL,
	[calendarioFK] [int] NULL,
	[saldo] [float] NULL,
	[insertTimestamp] [datetime] NULL,
	[updateTimestamp] [datetime] NULL)
GO

/****** Object:  Procedure [atualizaFato_Saldo_da_Loja]  ******/
/****** ISSO AQUI ABAIXO COMPREENDE O SCD... ******/
CREATE PROCEDURE atualizaFato_Saldo_da_Loja AS
BEGIN
	/****** AQUI NESTE BLOCO O QUANDO HÁ NOVA TUPLA INSERIDA EM RH QUE AINDA NÃO ESTEJA NO FATO ALI ******/
	INSERT INTO [DDS].dbo.Fato_Saldo_da_Loja (cnpjFK,empresa,saldo,insertTimestamp,updateTimestamp)
	SELECT  [NDS].dbo.RH.cnpjPK, 
			[NDS].dbo.RH.nomeFantasia,
			[NDS].dbo.Caixa.saldo,
			getDate(),
			getDate()
	FROM [NDS].dbo.RH INNER JOIN [NDS].dbo.Caixa ON [NDS].dbo.RH.cnpjPK = [NDS].dbo.Caixa.cnpjFK
	WHERE NOT EXISTS (
		SELECT * FROM [DDS].dbo.Fato_Saldo_da_Loja WHERE cnpjFK = [NDS].dbo.RH.cnpjPK
	)

	/****** AQUI NESTE NOVO BLOCO O QUANDO O SCD IDENTIFICA UMA ALTERAÇÃO E 
	NÃO NECESSITO INSERIR A TUPLA INTEIRA NOVAMENTE ******/
	UPDATE Fato_Saldo_da_Loja SET Fato_Saldo_da_Loja.saldo = [NDS].dbo.Caixa.saldo,
	updateTimestamp = getDate() FROM Fato_Saldo_da_Loja
	INNER JOIN [NDS].dbo.Caixa ON [NDS].dbo.Caixa.cnpjFK = Fato_Saldo_da_Loja.cnpjFK
	WHERE Fato_Saldo_da_Loja.cnpjFK = [NDS].dbo.Caixa.cnpjFK AND
	[NDS].dbo.Caixa.dataReceita > dbo.Fato_Saldo_da_Loja.updateTimestamp 
END
GO

/****** AQUI VOCÊ DEVA EXECUTAR A PROCEDURE QUANDO QUER ATUALIZAR O FATO ******/
/****** OBSERVE O SCD (SLOWLY CHANGING DIMENSION) ... ******/
EXEC atualizaFato_Saldo_da_Loja
GO