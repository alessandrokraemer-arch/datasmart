USE [METADATA]
GO

/****** Object:  Table [dbo].[DefinicaoDados]    Script Date: 14/10/2026 13:01:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DefinicaoDados](
	[idPK] [int] IDENTITY(1,1) NOT NULL,
	[tabFK] [int] NULL,
	[tipoColunaFK] [int] NULL,
	[descricao] [varchar](255) NULL,
	[exemplificacaoValor] [varchar](255) NULL,
	[colunaOriginalFK] [int] NULL,
	[createTimestamp] [date] NULL,
	[updateTimestamp] [date] NULL
) ON [PRIMARY]
GO
