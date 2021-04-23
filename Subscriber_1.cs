using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace azure_pub_sub
{
    public static class Subscriber_1
    {
        [FunctionName("Subscriber_1")]
        public static void Run([ServiceBusTrigger("az-pubsub-topic", "az-pubsub-subscription-1", Connection = "CONNECTION_STRING")]string topicItem, ILogger log)
        {
            log.LogInformation("Subscriber-1");
            log.LogInformation($"{topicItem}");
        }
    }
}
