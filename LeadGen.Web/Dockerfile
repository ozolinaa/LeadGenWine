FROM microsoft/dotnet:2.1-aspnetcore-runtime AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /src
COPY LeadGen.Web/LeadGen.Web.csproj LeadGen.Web/
COPY LeadGen.Code/LeadGen.Code.csproj LeadGen.Code/
RUN dotnet restore LeadGen.Web/LeadGen.Web.csproj
COPY . .
WORKDIR /src/LeadGen.Web
RUN dotnet build LeadGen.Web.csproj -c Release -o /app

FROM build AS publish
RUN dotnet publish LeadGen.Web.csproj -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .

RUN apt-get update \
    && apt-get install -y --no-install-recommends libgdiplus libc6-dev \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["dotnet", "LeadGen.Web.dll"]
