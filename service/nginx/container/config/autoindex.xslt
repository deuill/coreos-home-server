<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:func="http://exslt.org/functions" xmlns:str="http://exslt.org/strings" version="1.0" extension-element-prefixes="func str">
  <xsl:output method="html" html-version="5" encoding="utf-8" doctype-public=""/>
  <xsl:strip-space elements="*"/>
  <xsl:template name="size">
    <xsl:param name="bytes"/>
    <xsl:choose>
      <xsl:when test="$bytes &lt; 1000"><xsl:value-of select="$bytes"/>B</xsl:when>
      <xsl:when test="$bytes &lt; 1048576"><xsl:value-of select="format-number($bytes div 1024, '0.0')"/>KB</xsl:when>
      <xsl:when test="$bytes &lt; 1073741824"><xsl:value-of select="format-number($bytes div 1048576, '0.0')"/>MB</xsl:when>
      <xsl:otherwise><xsl:value-of select="format-number(($bytes div 1073741824), '0.0')"/>GB</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="timestamp">
    <xsl:param name="iso-timestamp"/>
    <xsl:value-of select="concat(substring($iso-timestamp, 0, 11), ' ', substring($iso-timestamp, 12, 5))"/>
  </xsl:template>
  <xsl:template match="directory">
    <tr>
      <td class="icon">
        <svg width="20" height="20">
          <use href="#icon-folder"/>
        </svg>
      </td>
      <td class="name">
        <a href="{str:encode-uri(current(),true())}/">
          <xsl:value-of select="."/>
        </a>
      </td>
      <td class="time">
        <xsl:call-template name="timestamp">
          <xsl:with-param name="iso-timestamp" select="@mtime"/>
        </xsl:call-template>
      </td>
      <td class="size"/>
    </tr>
  </xsl:template>
  <xsl:template match="file">
    <tr>
      <td class="icon">
        <svg width="20" height="20">
          <use href="#icon-file"/>
        </svg>
      </td>
      <td class="name">
        <a href="{str:encode-uri(current(),true())}" target="_blank">
          <xsl:value-of select="."/>
        </a>
      </td>
      <td class="time">
        <xsl:call-template name="timestamp">
          <xsl:with-param name="iso-timestamp" select="@mtime"/>
        </xsl:call-template>
      </td>
      <td class="size">
        <xsl:call-template name="size">
          <xsl:with-param name="bytes" select="@size"/>
        </xsl:call-template>
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="/">
    <html>
      <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>
          Index of <xsl:value-of select="$uri"/>
        </title>
        <style>
          body {
            font-family: sans-serif;
            max-width: 768px;
            margin: 32px auto;
            overflow: auto;
          }

          ul {
            margin: 0;
            padding: 0;
            flex-wrap: wrap;
            list-style: none;
          }

          li + li::before {
            content: " / ";
            opacity: 0.6;
          }

          li {
            display: inline;
          }

          li, li a {
            word-break: break-all;
          }

          a {
            text-decoration: none;
            color: inherit;
          }

          a:hover {
            opacity: 0.5;
          }

          table {
            overflow: hidden;
            width: 100%;
            border-spacing: 0;
          }

          td, th {
            padding: 14px;
          }

          .icon {
            width: 0;
            padding-left: 16px;
            padding-right: 0;
          }

          .name {
            text-align: left;
          }

          .time {
            text-align: center;
            white-space: nowrap;
          }

          .size {
            text-align: right;
            white-space: nowrap;
          }

          div {
            display: flex;
            justify-content: space-between;
          }

          td &gt; svg {
            vertical-align: middle;
          }

          tbody tr:nth-child(even) {
            background-color: #eee;
          }

          th {
            background-color: lightgrey;
          }

          @media (max-width: 767px) {
            tr &gt; *:nth-child(3) {
              display: none;
            }

            body {
              margin: 0;
            }
          }

          @media (min-width: 769px) {
            table {
              border: 4px solid lightgrey;
            }
          }

          @media (prefers-color-scheme: dark) and (min-width: 769px) {
            table {
              border-color: #444;
            }
          }

          @media (prefers-color-scheme: dark) {
            html {
              background-color: #222;
              color: #eee;
            }

            tbody tr:nth-child(even) {
              background-color: #333;
            }

            th {
              background-color: #444;
            }
          }
        </style>
      </head>
      <body>
        <table>
          <thead>
            <tr>
              <td colspan="2" class="name">
                Index of <xsl:value-of select="$uri"/>
              </td>
              <td colspan="2" class="size"><xsl:value-of select="count(//directory)"/>
                folder<xsl:if test="count(//directory) != 1">s</xsl:if>,
                <xsl:value-of select="count(//file)"/>
                file<xsl:if test="count(//file) != 1">s</xsl:if>
              </td>
            </tr>
            <tr>
              <th class="icon"/>
              <th class="name">Filename</th>
              <th class="time">Last Modified</th>
              <th class="size">Size</th>
            </tr>
          </thead>
          <tbody>
            <xsl:if test="$uri != '/'">
              <tr>
                <td class="icon">
                  <svg width="20" height="20">
                    <use href="#icon-up"/>
                  </svg>
                </td>
                <td class="name">
                  <a href="../">Go Up</a>
                </td>
                <td class="time"/>
                <td class="size"/>
              </tr>
            </xsl:if>
            <xsl:apply-templates/>
          </tbody>
        </table>
        <svg hidden="hidden">
          <defs>
            <symbol id="icon-file" viewBox="0 0 16 16">
              <path fill="currentColor" d="M11.724 5.333h-2.391v-2.391zM13.805 5.529l-4.667-4.667c-0.061-0.061-0.135-0.111-0.216-0.145s-0.169-0.051-0.255-0.051h-4.667c-0.552 0-1.053 0.225-1.414 0.586s-0.586 0.862-0.586 1.414v10.667c0 0.552 0.225 1.053 0.586 1.414s0.862 0.586 1.414 0.586h8c0.552 0 1.053-0.225 1.414-0.586s0.586-0.862 0.586-1.414v-7.333c0-0.184-0.075-0.351-0.195-0.471zM8 2v4c0 0.368 0.299 0.667 0.667 0.667h4v6.667c0 0.184-0.074 0.35-0.195 0.471s-0.287 0.195-0.471 0.195h-8c-0.184 0-0.35-0.074-0.471-0.195s-0.195-0.287-0.195-0.471v-10.667c0-0.184 0.074-0.35 0.195-0.471s0.287-0.195 0.471-0.195z"/>
            </symbol>
            <symbol id="icon-folder" viewBox="0 0 16 16">
              <path fill="currentColor" d="M15.333 12.667v-7.333c0-0.552-0.225-1.053-0.586-1.414s-0.862-0.586-1.414-0.586h-5.643l-1.135-1.703c-0.121-0.18-0.324-0.297-0.555-0.297h-3.333c-0.552 0-1.053 0.225-1.414 0.586s-0.586 0.862-0.586 1.414v9.333c0 0.552 0.225 1.053 0.586 1.414s0.862 0.586 1.414 0.586h10.667c0.552 0 1.053-0.225 1.414-0.586s0.586-0.862 0.586-1.414zM14 12.667c0 0.184-0.074 0.35-0.195 0.471s-0.287 0.195-0.471 0.195h-10.667c-0.184 0-0.35-0.074-0.471-0.195s-0.195-0.287-0.195-0.471v-9.333c0-0.184 0.074-0.35 0.195-0.471s0.287-0.195 0.471-0.195h2.977l1.135 1.703c0.128 0.191 0.337 0.295 0.555 0.297h6c0.184 0 0.35 0.074 0.471 0.195s0.195 0.287 0.195 0.471z"/>
            </symbol>
            <symbol id="icon-up" viewBox="0 0 24 24">
              <path fill="currentColor" d="M13.2929 9.70711C13.6834 10.0976 14.3166 10.0976 14.7071 9.70711C15.0976 9.31658 15.0976 8.68342 14.7071 8.29289L9.70711 3.29289C9.31658 2.90237 8.68342 2.90237 8.29289 3.29289L3.29289 8.29289C2.90237 8.68342 2.90237 9.31658 3.29289 9.70711C3.68342 10.0976 4.31658 10.0976 4.70711 9.70711L8 6.41421V16C8 17.3261 8.52678 18.5979 9.46447 19.5355C10.4021 20.4732 11.6739 21 13 21H20C20.5523 21 21 20.5523 21 20C21 19.4477 20.5523 19 20 19H13C12.2044 19 11.4413 18.6839 10.8787 18.1213C10.3161 17.5587 10 16.7956 10 16V6.41421L13.2929 9.70711Z"/>
            </symbol>
          </defs>
        </svg>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
