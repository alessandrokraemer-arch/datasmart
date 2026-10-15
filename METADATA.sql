USE [master]
GO

CREATE DATABASE METADATA
GO

USE [METADATA]
GO

/****** Object:  Table [dbo].[DefinicaoDado]    Script Date: 15/10/2026 20:34:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TipoColuna](
	[idPK] [int] IDENTITY(1,1) NOT NULL,
	[tipo] [varchar](100) NULL,
	[localizacao] [varchar](100) NULL,
	[descricao] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[idPK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[EstruturaTabela](
	[idPK] [int] IDENTITY(1,1) NOT NULL,
	[tabNome] [varchar](255) NULL,
	[descricao] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[idPK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[MapaDado](
	[idPK] [int] IDENTITY(1,1) NOT NULL,
	[colIdTipoFK] [int] NULL,
	[sourceColIdFK] [int] NULL,
	[createTimestamp] [date] NULL,
	[updateTimestamp] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[idPK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[MapaDado]  WITH CHECK ADD  CONSTRAINT [FK_MapaDado_TipoColuna] FOREIGN KEY([colIdTipoFK])
REFERENCES [dbo].[TipoColuna] ([idPK])
GO

ALTER TABLE [dbo].[MapaDado] CHECK CONSTRAINT [FK_MapaDado_TipoColuna]
GO

ALTER TABLE [dbo].[MapaDado]  WITH CHECK ADD  CONSTRAINT [FK_MapaDado_TipoColuna1] FOREIGN KEY([sourceColIdFK])
REFERENCES [dbo].[TipoColuna] ([idPK])
GO

ALTER TABLE [dbo].[MapaDado] CHECK CONSTRAINT [FK_MapaDado_TipoColuna1]
GO

CREATE TABLE [dbo].[DefinicaoDado](
	[idPK] [int] IDENTITY(1,1) NOT NULL,
	[tabIdFK] [int] NULL,
	[colIdTipoFK] [int] NULL,
	[descricao] [varchar](255) NULL,
	[exemplificacaoValor] [varchar](255) NULL,
	[colunaOriginalFK] [int] NULL,
	[createTimestamp] [date] NULL,
	[updateTimestamp] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[idPK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DefinicaoDado]  WITH CHECK ADD  CONSTRAINT [FK_DefinicaoDado_EstruturaTabela] FOREIGN KEY([tabIdFK])
REFERENCES [dbo].[EstruturaTabela] ([idPK])
GO

ALTER TABLE [dbo].[DefinicaoDado] CHECK CONSTRAINT [FK_DefinicaoDado_EstruturaTabela]
GO

ALTER TABLE [dbo].[DefinicaoDado]  WITH CHECK ADD  CONSTRAINT [FK_DefinicaoDado_TipoColuna] FOREIGN KEY([colIdTipoFK])
REFERENCES [dbo].[TipoColuna] ([idPK])
GO

ALTER TABLE [dbo].[DefinicaoDado] CHECK CONSTRAINT [FK_DefinicaoDado_TipoColuna]
GO

ALTER TABLE [dbo].[DefinicaoDado]  WITH CHECK ADD  CONSTRAINT [FK_DefinicaoDado_TipoColuna1] FOREIGN KEY([colunaOriginalFK])
REFERENCES [dbo].[TipoColuna] ([idPK])
GO

ALTER TABLE [dbo].[DefinicaoDado] CHECK CONSTRAINT [FK_DefinicaoDado_TipoColuna1]
GO


