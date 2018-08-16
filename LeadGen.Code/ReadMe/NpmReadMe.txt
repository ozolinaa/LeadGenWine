http://www.catrina.me/asp-net-core-easy-transition-of-bower-to-npm/
https://wildermuth.com/2017/11/19/ASP-NET-Core-2-0-and-the-End-of-Bower
https://docs.microsoft.com/en-us/aspnet/core/client-side/bundling-and-minification?view=aspnetcore-2.1&tabs=netcore-cli%2Caspnetcore2x

LeadGen.Web\bundleconfig.json
"node_modules/jquery/dist/(*.css|!(*.min.css)"


  <ItemGroup>
    <None Include="node_modules\bootstrap\dist\**" Link="wwwroot\lib\node_modules\bootstrap\dist\%(RecursiveDir)%(Filename)%(Extension)" OutputDirectory="wwwroot\lib\node_modules\bootstrap\dist" CopyToOutputDirectory="Always"  />
  </ItemGroup>
mklink /J "D:\Code\LeadGenWine\LeadGen.Web\wwwroot\lib\node_modules" "D:\Code\LeadGenWine\LeadGen.Web\node_modules"