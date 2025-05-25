import 'package:bbtproje/domain/cubits/auth_cubit.dart';
import 'package:bbtproje/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        bloc: getIt<AuthCubit>(),
        builder: (context, state) {
          if (state is AuthLoggedIn &&
              state.name != "" &&
              state.name != null &&
              state.role != null &&
              (state.role == "Yönetici" ||
                  state.role == "Kullanıcı" ||
                  state.role == "Ziyaretçi")) {
            if (state.role == "Yönetici") {
              Future.microtask(() => context.go('/admin-home'));
            } else {
              Future.microtask(() => context.go('/user-home'));
            }
            return SizedBox();
          } else if (state is AuthLoggedIn) {
            Future.microtask(() => context.go('/role'));
            return SizedBox();
          } else if (state is AuthInitial) {
            return Row(
              children: [
                // Sol taraf: Giriş Formu
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: 400,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Görev Yönetime Hoş Geldiniz",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Hemen kullanmaya başlayın – ücretsizdir. Kredi kartı gerekmez.",
                            ),
                            const SizedBox(height: 30),

                            // Google ile devam et butonu (Özel Tasarım)
                            InkWell(
                              onTap: () async {
                                try {
                                  await getIt<AuthCubit>().signInWithGoogle();
                                } catch (e) {
                                  print('Google ile giriş hatası: $e');
                                }
                              },
                              child: Container(
                                height: 45,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/google_icon.png',
                                      height: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Google ile devam edin',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Text("VEYA"),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // E-mail input
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: "isim@şirket.com",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Devam et butonu (Özel Tasarım)
                            InkWell(
                              onTap: () {
                                if (emailController.text.isEmpty ||
                                    !emailController.text.contains('@')) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Geçerli bir email giriniz!",
                                      ),
                                    ),
                                  );
                                } else {
                                  getIt<AuthCubit>().setEmail(
                                    emailController.text.trim(),
                                  );
                                }
                              },
                              child: Container(
                                height: 45,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0073EA),
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

                            const SizedBox(height: 12),
                            Text.rich(
                              TextSpan(
                                text:
                                    "Devam ederek, aşağıdaki hususları kabul etmiş olursunuz:\n",
                                children: [
                                  TextSpan(
                                    text: "Hizmet Şartları",
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  const TextSpan(text: " ve "),
                                  TextSpan(
                                    text: "Gizlilik Politikası",
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Sağ taraf: Görsel Alan
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
          } else if (state is AuthEmailIn) {
            final state = getIt<AuthCubit>().state as AuthEmailIn;

            return Row(
              children: [
                // Sol taraf: Giriş Formu
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: SizedBox(
                        width: 400,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // E-mail input
                            TextField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                hintText: "sifre",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            InkWell(
                              onTap: () {
                                if (passwordController.text.isEmpty ||
                                    passwordController.text.length < 8) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Geçerli bir şifre giriniz (en az 8 karakter)!",
                                      ),
                                    ),
                                  );
                                } else {
                                  print("email");
                                  print(state.email);
                                  print("password");
                                  print(passwordController.text);

                                  getIt<AuthCubit>().loginOrRegisterWithEmail(
                                    state.email,
                                    passwordController.text.trim(),
                                  );
                                }
                              },
                              child: Container(
                                height: 45,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0073EA),
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

                            const SizedBox(height: 12),
                            Text.rich(
                              TextSpan(
                                text:
                                    "Devam ederek, aşağıdaki hususları kabul etmiş olursunuz:\n",
                                children: [
                                  TextSpan(
                                    text: "Hizmet Şartları",
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  const TextSpan(text: " ve "),
                                  TextSpan(
                                    text: "Gizlilik Politikası",
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Sağ taraf: Görsel Alan
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
            print(getIt<AuthCubit>().state);
            return SizedBox();
          }
        },
      ),
    );
  }
}
