using CommandLine;
using dotnet_sfl_tool.Interfaces;

namespace dotnet_sfl_tool
{
    internal class App
    {
        private readonly IConvertService _service;
        private readonly ParserResult<CommandLineParameters> _parserResult;

        public App(IConvertService service, ParserResult<CommandLineParameters> parserResult)
        {
            _service = service;
            _parserResult = parserResult;
        }

        public async Task Run()
        {
            if (!_parserResult.Errors.Any())
                await _service.Run();
        }
    }
}