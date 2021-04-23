using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace azure_pub_sub
{
    public static class Publisher
    {
        [FunctionName("Publisher")]
        [return: ServiceBus("az-pubsub-topic", Connection = "CONNECTION_STRING")]
        public static string Run([TimerTrigger("0 */5 * * * *")]TimerInfo myTimer, ILogger log)
        {
            log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");

            return JsonConvert.SerializeObject(new {
                Id = 1,
                Msg = "Hello world",
                Date = DateTime.Now
            });
        }
    }
}
