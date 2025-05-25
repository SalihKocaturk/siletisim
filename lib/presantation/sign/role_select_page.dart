import 'package:bbtproje/domain/cubits/auth_cubit.dart';
import 'package:bbtproje/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  final TextEditingController nameController = TextEditingController();
  String? selectedRole;

  final roles = ['Yönetici', 'Kullanıcı', 'Ziyaretçi'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isValid =
        nameController.text.trim().isNotEmpty && selectedRole != null;

    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        bloc: getIt<AuthCubit>(),
        builder: (context, state) {
          if (state is AuthLoggedIn) {
            final mystate = getIt<AuthCubit>().state as AuthLoggedIn;
            return Row(
              children: [
                // Sol taraf: Form
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 60,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Adınızı Girin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 400,
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: 'Adınız',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Mevcut rolünüzü nasıl tanımlarsınız?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children:
                              roles.map((role) {
                                return ChoiceChip(
                                  label: Text(role),
                                  selected: selectedRole == role,
                                  onSelected:
                                      (_) =>
                                          setState(() => selectedRole = role),
                                  selectedColor: const Color(0xFF0073EA),
                                  labelStyle: TextStyle(
                                    color:
                                        selectedRole == role
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                  backgroundColor: Colors.grey.shade200,
                                );
                              }).toList(),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 200,
                          child: Align(
                            alignment: Alignment.bottomLeft,

                            child: InkWell(
                              onTap: () async {
                                getIt<AuthCubit>().setRoleAndName(
                                  selectedRole!,
                                  nameController.text.trim(),
                                );
                                await Future.delayed(
                                  const Duration(milliseconds: 2000),
                                );

                                if (selectedRole == "Yönetici") {
                                  context.go('/admin-home');
                                } else if (selectedRole == "Kullanıcı") {
                                  context.go("/user-home");
                                }
                              },
                              child: Container(
                                height: 45,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6558F5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Devam et',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sağ taraf: Görsel
                screenWidth > 800
                    ? Expanded(
                      flex: 1,
                      child: Container(
                        color: const Color(0xFF6558F5),
                        child: Center(
                          child: Image.asset(
                            'assets/images/login_illustration.png',
                            width: 600,
                            height: 500,
                          ),
                        ),
                      ),
                    )
                    : const SizedBox(),
              ],
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
