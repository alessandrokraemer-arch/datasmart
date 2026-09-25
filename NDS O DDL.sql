/****** 
O SCRIPT EM QUESTÃO ABRANGE A LITERATURA DO VINCENT, RAINARDI, DATA WAREHOUSE WITH EXAMPLES IN SQL SERVER, APRESS, 2008.
NESSE LIVRO DESTACO QUE A FONTE É A INDÚSTRIA...
******/

USE [master]
GO

CREATE DATABASE [NDS]
GO

USE [NDS]
GO

/****** Object:  Table [NDS].dbo.[Pais]  ******/
CREATE TABLE [NDS].[dbo].[Pais](
	[siglaPK] [varchar](3) NOT NULL PRIMARY KEY,
	[nome] [varchar](50) NOT NULL)
GO

/****** Object:  Table [dbo].[Estado]  ******/
CREATE TABLE [NDS].[dbo].[Estado](
	[siglaPK] [varchar](2) NOT NULL PRIMARY KEY,
	[nome] [varchar](50) NOT NULL,
	[paisSiglaFK] [varchar](3) NOT NULL)
GO

ALTER TABLE [NDS].[dbo].[Estado]  WITH CHECK ADD  CONSTRAINT [FK_Estado_Pais] FOREIGN KEY([paisSiglaFK])
REFERENCES [NDS].[dbo].[Pais] ([siglaPK])
GO

/****** Object:  Table [dbo].[RH]  ******/
CREATE TABLE [NDS].[dbo].[RH](
	[cnpjPK] [varchar](14) NOT NULL PRIMARY KEY,
	[nomeFantasia] [varchar](50) NOT NULL,
	[cidade] [varchar](50) NOT NULL,
	[estadoSiglaFK] [varchar](2) NOT NULL)
GO

ALTER TABLE [NDS].[dbo].[RH]  WITH CHECK ADD  CONSTRAINT [FK_RH_Estado] FOREIGN KEY([estadoSiglaFK])
REFERENCES [NDS].[dbo].[Estado] ([siglaPK])
GO

/****** Object:  Table [dbo].[Caixa]  ******/
CREATE TABLE [NDS].[dbo].[Caixa](
	[cnpjFK] [varchar](14) NOT NULL PRIMARY KEY,
	[saldo] [float] NOT NULL,
	[dataReceita] [datetime] NOT NULL)
GO

ALTER TABLE [NDS].[dbo].[Caixa]  WITH CHECK ADD  CONSTRAINT [FK_Caixa_RH] FOREIGN KEY([cnpjFK])
REFERENCES [NDS].[dbo].[RH] ([cnpjPK])
GO

/****** Object:  Table [dbo].[Historia]  ******/
CREATE TABLE [NDS].[dbo].[Historia](
	[cnpjFK] [varchar](14) NOT NULL,
	[externoPK] [varchar](50) NOT NULL PRIMARY KEY,
	[valor] [float] NOT NULL,
	[operacao] [varchar](9) NOT NULL,
	[dataMovimento] [datetime] NOT NULL)
GO

ALTER TABLE [NDS].[dbo].[Historia]  WITH CHECK ADD  CONSTRAINT [FK_Historia_RH] FOREIGN KEY([cnpjFK])
REFERENCES [NDS].[dbo].[RH] ([cnpjPK])
GO

/****** Object:  Table [dbo].[Departamento]  ******/
CREATE TABLE [NDS].[dbo].[Departamento](
	[idPK] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[nome] [varchar](50) NOT NULL,
	[telefonePK] [varchar](20) NOT NULL,
	[ramalPK] [varchar](4) NOT NULL)
GO

/****** Object:  Table [dbo].[Funcionario]  ******/
CREATE TABLE [NDS].[dbo].[Funcionario](
	[cpfPK] [varchar](14) NOT NULL PRIMARY KEY,
	[primeiroNome] [varchar](50) NOT NULL,
	[sobrenome] [varchar](50) NOT NULL)
GO

/****** Object:  Table [dbo].[Funcionario]  ******/
CREATE TABLE [NDS].[dbo].[EquipeAtendimento](
	[cpfPK] [varchar](14) NOT NULL PRIMARY KEY,
	[dptoIdFK] [int] NOT NULL)
GO

ALTER TABLE [NDS].[dbo].[EquipeAtendimento]  WITH CHECK ADD  CONSTRAINT [FK_EquipeAtendimento_Departamento] FOREIGN KEY([dptoIdFK])
REFERENCES [NDS].[dbo].[Departamento] ([idPK])
GO

ALTER TABLE [NDS].[dbo].[EquipeAtendimento]  WITH CHECK ADD  CONSTRAINT [FK_EquipeAtendimento_Funcionario] FOREIGN KEY([cpfPK])
REFERENCES [NDS].[dbo].[Funcionario] ([cpfPK])
GO


/****** ************************************** ******/


/****** Object:  Trigger [dbo].[insereCaixa] ******/
CREATE TRIGGER [dbo].[insereCaixa]
ON [dbo].[RH]
AFTER INSERT
AS
BEGIN
	DECLARE
	@cnpj varchar(14)

	DECLARE tuplas CURSOR FOR
		SELECT cnpjPK FROM INSERTED

	OPEN tuplas
	FETCH NEXT FROM tuplas INTO @cnpj
	WHILE @@FETCH_STATUS = 0
	BEGIN
		/**** SELECT @cnpj = cnpjPK FROM inserted ****/
		INSERT INTO Caixa (cnpjFK, saldo, dataReceita) VALUES (@cnpj,0, getdate())
		FETCH NEXT FROM tuplas INTO @cnpj
	END
	CLOSE tuplas
	DEALLOCATE tuplas
END
GO

/****** Object:  Trigger [dbo].[atualizaCaixa] ******/
CREATE TRIGGER [dbo].[atualizaCaixa] 
ON [dbo].[Historia]
AFTER INSERT
AS
BEGIN
	DECLARE
	@valor  float,
	@cnpj varchar(14)

	DECLARE tuplas CURSOR FOR
		SELECT cnpjFK, valor FROM INSERTED

	OPEN tuplas
	FETCH NEXT FROM tuplas INTO @cnpj, @valor
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE Caixa SET saldo = saldo + @valor, dataReceita = getDate() WHERE cnpjFK = @cnpj
		FETCH NEXT FROM tuplas INTO @cnpj, @valor
	END
	CLOSE tuplas
	DEALLOCATE tuplas
END
GO


/****** ************************************** ******/


/****** Object:  Procedure [dbo].[importaFonteCSV] ******/

CREATE PROCEDURE [dbo].[importaFonteCSV] @arquivo nvarchar(255), @tabela nvarchar(255)
AS
BEGIN
	DECLARE @Sql nvarchar(MAX);
	SET @Sql = '
		BULK INSERT '+ @tabela +' FROM '''+ @arquivo +''' WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = '';'',
		ROWTERMINATOR = ''\n''
	);
	';
	EXEC sp_executesql @Sql;
END


/****** ************************************** ******/


/****** Object:  View [dbo].[viewAoFato] ******/

CREATE VIEW [dbo].[viewAoFato]
AS
SELECT [NDS].dbo.RH.cnpjPK AS CNPJ, [NDS].dbo.RH.cidade AS CIDADE, [NDS].dbo.RH.estadoSiglaFK AS UF, 
[NDS].dbo.Estado.paisSiglaFK AS PA, [NDS].dbo.Pais.nome AS PAÍS, [NDS].dbo.Caixa.saldo AS SALDO
FROM [NDS].dbo.Pais INNER JOIN
[NDS].dbo.Estado ON [NDS].dbo.Pais.siglaPK = [NDS].dbo.Estado.paisSiglaFK INNER JOIN
[NDS].dbo.RH ON [NDS].dbo.Estado.siglaPK = [NDS].dbo.RH.estadoSiglaFK INNER JOIN
[NDS].dbo.Caixa ON [NDS].dbo.RH.cnpjPK = [NDS].dbo.Caixa.cnpjFK
GO

/****** VOCÊ PODE E DEVA APRIMORAR AO LONGO DO TEMPO ******/