using CommandLine;
using dotnet_sfl_tool;
using dotnet_sfl_tool.Interfaces;
using dotnet_sfl_tool.Services;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

static void ConfigureServices(IServiceCollection services, string[] args)
{
    // configure logging
    services.AddLogging(builder =>
    {
        builder.AddConsole();
        builder.AddDebug();
    });

    // add services:
    services.AddSingleton<ParserResult<CommandLineParameters>>(o =>
     {
         return Parser.Default.ParseArguments<CommandLineParameters>(args)
                              .WithParsed(o => { });
     });

    services.AddSingleton<CommandLineParameters>(x =>
    {
        return x.GetRequiredService<ParserResult<CommandLineParameters>>().Value;
    });

    services.AddScoped<IConvertService, ConvertService>();
    services.AddScoped<ISFLService, SFLService>();

    //add app
    services.AddTransient<App>();
}

// create service collection
var services = new ServiceCollection();

ConfigureServices(services, args);

// create service provider
using var serviceProvider = services.BuildServiceProvider();

// entry to run app
await serviceProvider.GetRequiredService<App>().Run();