import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imperio_tribal_app/shared/controllers/village_resources_controller.dart';

class ResourceItem extends StatelessWidget {
  final String icon;
  final int amount;
  final int maxCapacity;
  final bool isAtCapacity;

  const ResourceItem({
    super.key,
    required this.icon,
    required this.amount,
    required this.maxCapacity,
    required this.isAtCapacity,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.brown[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isAtCapacity ? Colors.red[200]! : Colors.brown[200]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/$icon.png', width: 20, height: 20),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                amount.toString(),
                style: TextStyle(
                  color: isAtCapacity ? Colors.red : Colors.brown[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StorageItem extends StatelessWidget {
  final int maxCapacity;

  const StorageItem({super.key, required this.maxCapacity});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.brown[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.brown[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/warehouse.png', width: 20, height: 20),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                maxCapacity.toString(),
                style: TextStyle(
                  color: Colors.brown[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VillageResources extends StatelessWidget {
  final int villageId;

  const VillageResources({super.key, required this.villageId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VillageResourcesController>(
      tag: 'village_$villageId',
    );

    return Obx(() {
      // Primeiro Obx só para loading e erros
      if (controller.isLoading.value && controller.resources.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.hasError.value) {
        return Text(controller.errorMessage.value);
      }

      if (controller.resources.value == null) {
        return const Text('Recursos não encontrados');
      }

      // Segundo Obx para os recursos
      return Obx(() {
        final resourceData = controller.resources.value;
        final capacity = controller.maxCapacity.value;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.brown[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.brown[200]!),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.brown[200]!.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ResourceItem(
                icon: 'wood',
                amount: resourceData?.wood ?? 0,
                maxCapacity: capacity,
                isAtCapacity: controller.isAtCapacity(resourceData?.wood ?? 0),
              ),
              const SizedBox(width: 4),
              ResourceItem(
                icon: 'clay',
                amount: resourceData?.clay ?? 0,
                maxCapacity: capacity,
                isAtCapacity: controller.isAtCapacity(resourceData?.clay ?? 0),
              ),
              const SizedBox(width: 4),
              ResourceItem(
                icon: 'iron',
                amount: resourceData?.iron ?? 0,
                maxCapacity: capacity,
                isAtCapacity: controller.isAtCapacity(resourceData?.iron ?? 0),
              ),
              const SizedBox(width: 4),
              StorageItem(maxCapacity: capacity),
            ],
          ),
        );
      });
    });
  }
}
