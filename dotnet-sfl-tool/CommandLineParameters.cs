using CommandLine;

namespace dotnet_sfl_tool
{
    internal class CommandLineParameters
    {
        [Option('p', "inputPath", Required = true, HelpText = "Set path input results.")]
        public string path { get; set; }

        [Option('o', "outputPath", Required = true, HelpText = "Set path output results.")]
        public string output { get; set; }
    }

    internal enum SFLToolType
    {
        Flacoco,
        GZoltar,
        JaguarControlFlow,
        Jaguar2ControlFlow
    }
}
